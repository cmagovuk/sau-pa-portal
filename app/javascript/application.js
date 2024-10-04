import { initAll } from "govuk-frontend";

initAll();

document.addEventListener('DOMContentLoaded', () => {
    var alreadyClicked = false;

    onceClicked = (e) => {
        if (alreadyClicked) {
            e.preventDefault();
            return false;
        }
        alreadyClicked = true;
    };

    const inputFileUpload = document.getElementsByClassName("upload-input")[0];
    if (inputFileUpload) {
        const uploadFileButton = document.getElementsByClassName("upload-files-button")[0];
        if (uploadFileButton) {
            const continueButton = document.getElementsByClassName("upload-continue-button")[0];
            inputFileUpload.addEventListener('change', (e) => {
                if (continueButton) {
                    continueButton.disabled = true;
                }
                inputFileUpload.form.submit();
                inputFileUpload.disabled = true;
            });

            uploadFileButton.style.display = "none";
        }
    }

    const filter_btn = document.getElementsByClassName("sau-filter-btn")[0];
    if (filter_btn) {
        const filters = document.getElementsByClassName("sau-filter");
        if (filters) {
            filter_btn.style.display = "none";
            for (let idx = 0; idx < filters.length; idx++) {
                filters[idx].addEventListener('change', (e) => {
                    e.target.form.submit();
                })                
            }
        }
    }

    const inputFormSelect = document.getElementsByClassName("sau-form-select")[0];
    if (inputFormSelect) {
        const divOtherForm = document.getElementsByClassName("sau-other-form")[0];
        const divBudget = document.getElementsByClassName("sau-budget")[0];
        const divTaxAmount = document.getElementsByClassName("sau-tax-amount")[0];
        if (divOtherForm && divBudget && divTaxAmount) {
            setDivs(inputFormSelect.value);
            inputFormSelect.addEventListener('change', (e) => {
                setDivs(e.target.value);
            });

            function setDivs(value) {
                divOtherForm.style.display = value == "other" ? "block":"none"
                divBudget.style.display = value == "tax" ? "none":"block"
                divTaxAmount.style.display = value == "tax" ? "block":"none"
            }
        }
    }

    const inputTaxSelect = document.getElementsByClassName("sau-tax-select")[0];
    if (inputTaxSelect) {
        const divTaxRange = document.getElementsByClassName("sau-tax-range")[0];
        if (inputTaxSelect) {
            setTaxDivs(inputTaxSelect.value);
            inputTaxSelect.addEventListener('change', (e) => {
                setTaxDivs(e.target.value);
            });

            function setTaxDivs(value) {
                divTaxRange.style.display = value == "over_30000" ? "block":"none"
            }
        }
    }

    const submissionButton = document.getElementsByClassName("sau-submission-button")[0];
    if (submissionButton) {
        submissionButton.addEventListener('click', onceClicked);
        addEventListener('pageshow', (e) => {
            alreadyClicked = false;
        });
    }

    const reportDueDate =  document.getElementsByClassName("sau-report-due")[0];
    if (reportDueDate) {
        const warningText = document.getElementsByClassName("sau-date-warning")[0];
        if (warningText) {
            const maxDate = new Date(reportDueDate.getAttribute("data-sau-max"));
            warningText.style.display = reportDueDate.value == "" || new Date(reportDueDate.value) <= maxDate ? "none" : "block";
            reportDueDate.addEventListener('change', (e) => {
                warningText.style.display = new Date(e.target.value) <= maxDate ?  "none" : "block";
            });
        }
    }

    const paOrg1Select = document.getElementsByClassName("pa-org-1-select")[0];
    if (paOrg1Select) {
        const paOrg2Select = document.getElementsByClassName("pa-org-2-select")[0];
        const paOrg1 = document.getElementsByClassName("pa-org-1")[0];
        const paOrg2 = document.getElementsByClassName("pa-org-2")[0];
        if (paOrg1.value === "") {
            document.getElementsByClassName("pa-org-1-fg")[0].style.display = "block";
            document.getElementsByClassName("pa-org-2-fg")[0].style.display = "block";
        }
        else {
            const paOrg2Select = document.getElementsByClassName("pa-org-2-select")[0];
            // Hide unrelated values
            for (let index = 0; index < paOrg2Select.options.length; index++) {
                const element = paOrg2Select.options[index];
                if (element.parentElement.tagName === "OPTGROUP") {
                    element.hidden = (element.parentElement.label !== paOrg1.value);
                    element.parentElement.hidden = element.hidden;
                    element.selected = !element.hidden && (element.label === paOrg2.value);
                }
            }
            document.getElementsByClassName("pa-org-2-select-fg")[0].style.display = "block";
            if (paOrg2.value === "") {
                document.getElementsByClassName("pa-org-2-fg")[0].style.display = "block";
            }
        }


        paOrg1Select.addEventListener('change', (e) => {
            const paOrg1 = document.getElementsByClassName("pa-org-1")[0];
            const paOrg2 = document.getElementsByClassName("pa-org-2")[0];
            if (e.target.value === "") {
                paOrg1.value = "";
                paOrg2.value = "";
                document.getElementsByClassName("pa-org-1-fg")[0].style.display = "block";
                document.getElementsByClassName("pa-org-2-fg")[0].style.display = "block";
                document.getElementsByClassName("pa-org-2-select-fg")[0].style.display = "none";
            }
            else {
                paOrg1.value = e.target.value;
                document.getElementsByClassName("pa-org-1-fg")[0].style.display = "none";
                const paOrg2Select = document.getElementsByClassName("pa-org-2-select")[0];
                // Hide unrelated values
                for (let index = 0; index < paOrg2Select.options.length; index++) {
                    const element = paOrg2Select.options[index];
                    if (element.parentElement.tagName === "OPTGROUP") {
                        element.hidden = (element.parentElement.label !== e.target.value);
                        element.parentElement.hidden = element.hidden;
                        element.selected = !element.hidden && (element.label === paOrg2.value);
                    }
                }
                const paOrg2SelectFg = document.getElementsByClassName("pa-org-2-select-fg")[0].style.display = "block";
                if (paOrg2Select.selectedOptions[0].value === "") {
                    paOrg2.value = "";
                    const paOrg2Fg = document.getElementsByClassName("pa-org-2-fg")[0].style.display = "block";
                }
                else {
                    const paOrg2Fg = document.getElementsByClassName("pa-org-2-fg")[0].style.display = "none";
                }
            }
        });

        paOrg2Select.addEventListener('change', (e) => {
            const paOrg2 = document.getElementsByClassName("pa-org-2")[0];
            if (e.target.value === "") {
                paOrg2.value = "";
                document.getElementsByClassName("pa-org-2-fg")[0].style.display = "block";
            }
            else {
                paOrg2.value = e.target.value;
                document.getElementsByClassName("pa-org-2-fg")[0].style.display = "none";
            }
        });
    }
});


