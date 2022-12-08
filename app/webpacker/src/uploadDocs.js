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
        const continueButton = document.getElementsByClassName("upload-continue-button")[0];
        if (continueButton && uploadFileButton) {
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
        const divTaxRange = document.getElementsByClassName("sau-tax-range")[0];
        const inputTaxSelect = document.getElementsByClassName("sau-tax-select")[0];
        if (divOtherForm && divBudget && divTaxAmount) {
            setDivs(inputFormSelect.value);
            inputFormSelect.addEventListener('change', (e) => {
                setDivs(e.target.value);
            });

            if (inputTaxSelect) {
                setTaxDivs(inputTaxSelect.value);
                inputTaxSelect.addEventListener('change', (e) => {
                    setTaxDivs(e.target.value);
                });
            }

            function setDivs(value) {
                divOtherForm.style.display = value == "other" ? "block":"none"
                divBudget.style.display = value == "tax" ? "none":"block"
                divTaxAmount.style.display = value == "tax" ? "block":"none"
            }

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
});
