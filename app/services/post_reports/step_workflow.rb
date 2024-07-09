class PostReports::StepWorkflow
  attr_reader :request_id, :page_id

  STEPS = %w[referral_details principle_a principle_e principle_c principle_d principle_b principle_f principle_g ee_principles other_issues temp review].freeze

  def initialize(request_id, page_id)
    @request_id = request_id
    @page_id = page_id
  end

  def step_model
    sub_class = begin
      "PostReport::#{step.camelcase}".constantize
    rescue StandardError
      PostReport
    end
    @step_model ||= sub_class.find_by(request_id: request_id)
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
    @step ||= page_id.to_s.downcase
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
    STEPS.first
  end

  def completed_steps?
    uncompleted_steps.empty?
  end

private

  def determine_steps
    # this needs to work out all steps, given the current state of the step model
    calculated_steps = STEPS
    calculated_steps.freeze
  end

  def step_set
    @step_set ||= determine_steps
  end

  def uncompleted_steps
    step_set[0..-2].difference(step_model.completed_steps)
  end
end
