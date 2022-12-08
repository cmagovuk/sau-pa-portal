class Requests::StepWorkflow
  attr_reader :request

  INITIAL_STEPS = %w[referral_type].freeze
  CALL_STEPS = %w[call_in_direction call_in_type].freeze
  PAR_STEPS = %w[par_direction par_transparency].freeze
  SCHEME_STEPS = %w[scheme_info sectors descriptions legal purposes dates].freeze
  SUBSIDY_STEPS = %w[subsidy_info beneficiary goods_services locations sectors descriptions legal purposes].freeze
  CHARACTERISTICS_STEPS = %w[character_desc].freeze
  ASSESSMENT_STEPS = %w[ee_required assessment].freeze
  EE_ASSESSMENT_STEPS = %w[ee_assessment].freeze
  PAR_ASSESSMENT_STEPS = %w[par_assessment].freeze
  REVIEW_STEPS = %w[review].freeze

  def initialize(request)
    @request = request
  end

  def step_model
    sub_class = begin
      "Request::#{step.camelcase}".constantize
    rescue StandardError
      Request
    end
    @step_model ||= sub_class.find(session[:issue_id])
  end

  def next_step
    if completed_steps?
      step_set.last unless step == step_set.last
    else
      current_step_index = step_set.index(step)
      step_set[current_step_index + 1]
    end
  end

  def step_valid?
    step_set.include? step if step.present?
  end

  def step
    @step ||= params[:id].to_s.downcase
  end

  def update_completed_steps
    array = step_model.completed_steps.map { |o| o }
    step_model.update!(completed_steps: array.append(step)) unless array.include?(step)
  end

  def previous_step
    if completed_steps? && step != step_set.last
      step_set.last
    else
      current_step_index = step_set.index(step)
      previous_step_index = current_step_index - 1
      previous_step_index.negative? ? nil : step_set[previous_step_index]
    end
  end

  def missed_step
    uncompleted_steps[0]
  end

  def first_step
    INITIAL_STEPS.first
  end

  def completed_steps?
    uncompleted_steps.empty?
  end

private

  def session
    request.session
  end

  def params
    request.params
  end

  def determine_steps
    # this needs to work out all steps, given the current state of the step model
    calculated_steps = INITIAL_STEPS
    calculated_steps += CALL_STEPS if step_model.referral_type == "call"
    calculated_steps += PAR_STEPS if step_model.referral_type == "par"
    calculated_steps += if step_model.scheme_subsidy == "scheme"
                          SCHEME_STEPS
                        else
                          SUBSIDY_STEPS
                        end
    calculated_steps += CHARACTERISTICS_STEPS unless step_model.referral_type == "par" || (step_model.referral_type == "call" && step_model.call_in_type == "other")
    calculated_steps += PAR_ASSESSMENT_STEPS if step_model.referral_type == "par"
    calculated_steps += ASSESSMENT_STEPS unless step_model.referral_type == "par" && step_model.par_assessed == "n"
    calculated_steps += EE_ASSESSMENT_STEPS if step_model.ee_assess_required == "y" &&
      (step_model.referral_type != "par" || step_model.par_assessed == "y")
    calculated_steps += REVIEW_STEPS
    calculated_steps.freeze
  end

  def step_set
    @step_set ||= determine_steps
  end

  def uncompleted_steps
    step_set[0..-2].difference(step_model.completed_steps)
  end
end
