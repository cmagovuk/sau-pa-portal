// node_modules/govuk-frontend/dist/govuk/common/index.mjs
function mergeConfigs(...configObjects) {
  function flattenObject(configObject) {
    const flattenedObject = {};
    function flattenLoop(obj, prefix) {
      for (const [key, value] of Object.entries(obj)) {
        const prefixedKey = prefix ? `${prefix}.${key}` : key;
        if (value && typeof value === "object") {
          flattenLoop(value, prefixedKey);
        } else {
          flattenedObject[prefixedKey] = value;
        }
      }
    }
    flattenLoop(configObject);
    return flattenedObject;
  }
  const formattedConfigObject = {};
  for (const configObject of configObjects) {
    const obj = flattenObject(configObject);
    for (const [key, value] of Object.entries(obj)) {
      formattedConfigObject[key] = value;
    }
  }
  return formattedConfigObject;
}
function extractConfigByNamespace(configObject, namespace) {
  const newObject = {};
  for (const [key, value] of Object.entries(configObject)) {
    const keyParts = key.split(".");
    if (keyParts[0] === namespace) {
      if (keyParts.length > 1) {
        keyParts.shift();
      }
      const newKey = keyParts.join(".");
      newObject[newKey] = value;
    }
  }
  return newObject;
}
function getFragmentFromUrl(url) {
  if (!url.includes("#")) {
    return void 0;
  }
  return url.split("#").pop();
}
function getBreakpoint(name) {
  const property = `--govuk-frontend-breakpoint-${name}`;
  const value = window.getComputedStyle(document.documentElement).getPropertyValue(property);
  return {
    property,
    value: value || void 0
  };
}
function setFocus($element, options = {}) {
  var _options$onBeforeFocu;
  const isFocusable = $element.getAttribute("tabindex");
  if (!isFocusable) {
    $element.setAttribute("tabindex", "-1");
  }
  function onFocus() {
    $element.addEventListener("blur", onBlur, {
      once: true
    });
  }
  function onBlur() {
    var _options$onBlur;
    (_options$onBlur = options.onBlur) == null || _options$onBlur.call($element);
    if (!isFocusable) {
      $element.removeAttribute("tabindex");
    }
  }
  $element.addEventListener("focus", onFocus, {
    once: true
  });
  (_options$onBeforeFocu = options.onBeforeFocus) == null || _options$onBeforeFocu.call($element);
  $element.focus();
}
function isSupported($scope = document.body) {
  if (!$scope) {
    return false;
  }
  return $scope.classList.contains("govuk-frontend-supported");
}
function validateConfig(schema, config) {
  const validationErrors = [];
  for (const [name, conditions] of Object.entries(schema)) {
    const errors = [];
    for (const {
      required,
      errorMessage
    } of conditions) {
      if (!required.every((key) => !!config[key])) {
        errors.push(errorMessage);
      }
    }
    if (name === "anyOf" && !(conditions.length - errors.length >= 1)) {
      validationErrors.push(...errors);
    }
  }
  return validationErrors;
}

// node_modules/govuk-frontend/dist/govuk/common/normalise-dataset.mjs
function normaliseString(value) {
  if (typeof value !== "string") {
    return value;
  }
  const trimmedValue = value.trim();
  if (trimmedValue === "true") {
    return true;
  }
  if (trimmedValue === "false") {
    return false;
  }
  if (trimmedValue.length > 0 && isFinite(Number(trimmedValue))) {
    return Number(trimmedValue);
  }
  return value;
}
function normaliseDataset(dataset) {
  const out = {};
  for (const [key, value] of Object.entries(dataset)) {
    out[key] = normaliseString(value);
  }
  return out;
}

// node_modules/govuk-frontend/dist/govuk/errors/index.mjs
var GOVUKFrontendError = class extends Error {
  constructor(...args) {
    super(...args);
    this.name = "GOVUKFrontendError";
  }
};
var SupportError = class extends GOVUKFrontendError {
  /**
   * Checks if GOV.UK Frontend is supported on this page
   *
   * @param {HTMLElement | null} [$scope] - HTML element `<body>` checked for browser support
   */
  constructor($scope = document.body) {
    const supportMessage = "noModule" in HTMLScriptElement.prototype ? 'GOV.UK Frontend initialised without `<body class="govuk-frontend-supported">` from template `<script>` snippet' : "GOV.UK Frontend is not supported in this browser";
    super($scope ? supportMessage : 'GOV.UK Frontend initialised without `<script type="module">`');
    this.name = "SupportError";
  }
};
var ConfigError = class extends GOVUKFrontendError {
  constructor(...args) {
    super(...args);
    this.name = "ConfigError";
  }
};
var ElementError = class extends GOVUKFrontendError {
  constructor(messageOrOptions) {
    let message = typeof messageOrOptions === "string" ? messageOrOptions : "";
    if (typeof messageOrOptions === "object") {
      const {
        componentName,
        identifier,
        element,
        expectedType
      } = messageOrOptions;
      message = `${componentName}: ${identifier}`;
      message += element ? ` is not of type ${expectedType != null ? expectedType : "HTMLElement"}` : " not found";
    }
    super(message);
    this.name = "ElementError";
  }
};

// node_modules/govuk-frontend/dist/govuk/govuk-frontend-component.mjs
var GOVUKFrontendComponent = class {
  constructor() {
    this.checkSupport();
  }
  checkSupport() {
    if (!isSupported()) {
      throw new SupportError();
    }
  }
};

// node_modules/govuk-frontend/dist/govuk/i18n.mjs
var I18n = class _I18n {
  constructor(translations = {}, config = {}) {
    var _config$locale;
    this.translations = void 0;
    this.locale = void 0;
    this.translations = translations;
    this.locale = (_config$locale = config.locale) != null ? _config$locale : document.documentElement.lang || "en";
  }
  t(lookupKey, options) {
    if (!lookupKey) {
      throw new Error("i18n: lookup key missing");
    }
    if (typeof (options == null ? void 0 : options.count) === "number") {
      lookupKey = `${lookupKey}.${this.getPluralSuffix(lookupKey, options.count)}`;
    }
    const translationString = this.translations[lookupKey];
    if (typeof translationString === "string") {
      if (translationString.match(/%{(.\S+)}/)) {
        if (!options) {
          throw new Error("i18n: cannot replace placeholders in string if no option data provided");
        }
        return this.replacePlaceholders(translationString, options);
      }
      return translationString;
    }
    return lookupKey;
  }
  replacePlaceholders(translationString, options) {
    const formatter = Intl.NumberFormat.supportedLocalesOf(this.locale).length ? new Intl.NumberFormat(this.locale) : void 0;
    return translationString.replace(/%{(.\S+)}/g, function(placeholderWithBraces, placeholderKey) {
      if (Object.prototype.hasOwnProperty.call(options, placeholderKey)) {
        const placeholderValue = options[placeholderKey];
        if (placeholderValue === false || typeof placeholderValue !== "number" && typeof placeholderValue !== "string") {
          return "";
        }
        if (typeof placeholderValue === "number") {
          return formatter ? formatter.format(placeholderValue) : `${placeholderValue}`;
        }
        return placeholderValue;
      }
      throw new Error(`i18n: no data found to replace ${placeholderWithBraces} placeholder in string`);
    });
  }
  hasIntlPluralRulesSupport() {
    return Boolean("PluralRules" in window.Intl && Intl.PluralRules.supportedLocalesOf(this.locale).length);
  }
  getPluralSuffix(lookupKey, count) {
    count = Number(count);
    if (!isFinite(count)) {
      return "other";
    }
    const preferredForm = this.hasIntlPluralRulesSupport() ? new Intl.PluralRules(this.locale).select(count) : this.selectPluralFormUsingFallbackRules(count);
    if (`${lookupKey}.${preferredForm}` in this.translations) {
      return preferredForm;
    } else if (`${lookupKey}.other` in this.translations) {
      console.warn(`i18n: Missing plural form ".${preferredForm}" for "${this.locale}" locale. Falling back to ".other".`);
      return "other";
    }
    throw new Error(`i18n: Plural form ".other" is required for "${this.locale}" locale`);
  }
  selectPluralFormUsingFallbackRules(count) {
    count = Math.abs(Math.floor(count));
    const ruleset = this.getPluralRulesForLocale();
    if (ruleset) {
      return _I18n.pluralRules[ruleset](count);
    }
    return "other";
  }
  getPluralRulesForLocale() {
    const localeShort = this.locale.split("-")[0];
    for (const pluralRule in _I18n.pluralRulesMap) {
      const languages = _I18n.pluralRulesMap[pluralRule];
      if (languages.includes(this.locale) || languages.includes(localeShort)) {
        return pluralRule;
      }
    }
  }
};
I18n.pluralRulesMap = {
  arabic: ["ar"],
  chinese: ["my", "zh", "id", "ja", "jv", "ko", "ms", "th", "vi"],
  french: ["hy", "bn", "fr", "gu", "hi", "fa", "pa", "zu"],
  german: ["af", "sq", "az", "eu", "bg", "ca", "da", "nl", "en", "et", "fi", "ka", "de", "el", "hu", "lb", "no", "so", "sw", "sv", "ta", "te", "tr", "ur"],
  irish: ["ga"],
  russian: ["ru", "uk"],
  scottish: ["gd"],
  spanish: ["pt-PT", "it", "es"],
  welsh: ["cy"]
};
I18n.pluralRules = {
  arabic(n) {
    if (n === 0) {
      return "zero";
    }
    if (n === 1) {
      return "one";
    }
    if (n === 2) {
      return "two";
    }
    if (n % 100 >= 3 && n % 100 <= 10) {
      return "few";
    }
    if (n % 100 >= 11 && n % 100 <= 99) {
      return "many";
    }
    return "other";
  },
  chinese() {
    return "other";
  },
  french(n) {
    return n === 0 || n === 1 ? "one" : "other";
  },
  german(n) {
    return n === 1 ? "one" : "other";
  },
  irish(n) {
    if (n === 1) {
      return "one";
    }
    if (n === 2) {
      return "two";
    }
    if (n >= 3 && n <= 6) {
      return "few";
    }
    if (n >= 7 && n <= 10) {
      return "many";
    }
    return "other";
  },
  russian(n) {
    const lastTwo = n % 100;
    const last = lastTwo % 10;
    if (last === 1 && lastTwo !== 11) {
      return "one";
    }
    if (last >= 2 && last <= 4 && !(lastTwo >= 12 && lastTwo <= 14)) {
      return "few";
    }
    if (last === 0 || last >= 5 && last <= 9 || lastTwo >= 11 && lastTwo <= 14) {
      return "many";
    }
    return "other";
  },
  scottish(n) {
    if (n === 1 || n === 11) {
      return "one";
    }
    if (n === 2 || n === 12) {
      return "two";
    }
    if (n >= 3 && n <= 10 || n >= 13 && n <= 19) {
      return "few";
    }
    return "other";
  },
  spanish(n) {
    if (n === 1) {
      return "one";
    }
    if (n % 1e6 === 0 && n !== 0) {
      return "many";
    }
    return "other";
  },
  welsh(n) {
    if (n === 0) {
      return "zero";
    }
    if (n === 1) {
      return "one";
    }
    if (n === 2) {
      return "two";
    }
    if (n === 3) {
      return "few";
    }
    if (n === 6) {
      return "many";
    }
    return "other";
  }
};

// node_modules/govuk-frontend/dist/govuk/components/accordion/accordion.mjs
var Accordion = class _Accordion extends GOVUKFrontendComponent {
  /**
   * @param {Element | null} $module - HTML element to use for accordion
   * @param {AccordionConfig} [config] - Accordion config
   */
  constructor($module, config = {}) {
    super();
    this.$module = void 0;
    this.config = void 0;
    this.i18n = void 0;
    this.controlsClass = "govuk-accordion__controls";
    this.showAllClass = "govuk-accordion__show-all";
    this.showAllTextClass = "govuk-accordion__show-all-text";
    this.sectionClass = "govuk-accordion__section";
    this.sectionExpandedClass = "govuk-accordion__section--expanded";
    this.sectionButtonClass = "govuk-accordion__section-button";
    this.sectionHeaderClass = "govuk-accordion__section-header";
    this.sectionHeadingClass = "govuk-accordion__section-heading";
    this.sectionHeadingDividerClass = "govuk-accordion__section-heading-divider";
    this.sectionHeadingTextClass = "govuk-accordion__section-heading-text";
    this.sectionHeadingTextFocusClass = "govuk-accordion__section-heading-text-focus";
    this.sectionShowHideToggleClass = "govuk-accordion__section-toggle";
    this.sectionShowHideToggleFocusClass = "govuk-accordion__section-toggle-focus";
    this.sectionShowHideTextClass = "govuk-accordion__section-toggle-text";
    this.upChevronIconClass = "govuk-accordion-nav__chevron";
    this.downChevronIconClass = "govuk-accordion-nav__chevron--down";
    this.sectionSummaryClass = "govuk-accordion__section-summary";
    this.sectionSummaryFocusClass = "govuk-accordion__section-summary-focus";
    this.sectionContentClass = "govuk-accordion__section-content";
    this.$sections = void 0;
    this.browserSupportsSessionStorage = false;
    this.$showAllButton = null;
    this.$showAllIcon = null;
    this.$showAllText = null;
    if (!($module instanceof HTMLElement)) {
      throw new ElementError({
        componentName: "Accordion",
        element: $module,
        identifier: "Root element (`$module`)"
      });
    }
    this.$module = $module;
    this.config = mergeConfigs(_Accordion.defaults, config, normaliseDataset($module.dataset));
    this.i18n = new I18n(extractConfigByNamespace(this.config, "i18n"));
    const $sections = this.$module.querySelectorAll(`.${this.sectionClass}`);
    if (!$sections.length) {
      throw new ElementError({
        componentName: "Accordion",
        identifier: `Sections (\`<div class="${this.sectionClass}">\`)`
      });
    }
    this.$sections = $sections;
    this.browserSupportsSessionStorage = helper.checkForSessionStorage();
    this.initControls();
    this.initSectionHeaders();
    const areAllSectionsOpen = this.checkIfAllSectionsOpen();
    this.updateShowAllButton(areAllSectionsOpen);
  }
  initControls() {
    this.$showAllButton = document.createElement("button");
    this.$showAllButton.setAttribute("type", "button");
    this.$showAllButton.setAttribute("class", this.showAllClass);
    this.$showAllButton.setAttribute("aria-expanded", "false");
    this.$showAllIcon = document.createElement("span");
    this.$showAllIcon.classList.add(this.upChevronIconClass);
    this.$showAllButton.appendChild(this.$showAllIcon);
    const $accordionControls = document.createElement("div");
    $accordionControls.setAttribute("class", this.controlsClass);
    $accordionControls.appendChild(this.$showAllButton);
    this.$module.insertBefore($accordionControls, this.$module.firstChild);
    this.$showAllText = document.createElement("span");
    this.$showAllText.classList.add(this.showAllTextClass);
    this.$showAllButton.appendChild(this.$showAllText);
    this.$showAllButton.addEventListener("click", () => this.onShowOrHideAllToggle());
    if ("onbeforematch" in document) {
      document.addEventListener("beforematch", (event) => this.onBeforeMatch(event));
    }
  }
  initSectionHeaders() {
    this.$sections.forEach(($section, i) => {
      const $header = $section.querySelector(`.${this.sectionHeaderClass}`);
      if (!$header) {
        throw new ElementError({
          componentName: "Accordion",
          identifier: `Section headers (\`<div class="${this.sectionHeaderClass}">\`)`
        });
      }
      this.constructHeaderMarkup($header, i);
      this.setExpanded(this.isExpanded($section), $section);
      $header.addEventListener("click", () => this.onSectionToggle($section));
      this.setInitialState($section);
    });
  }
  constructHeaderMarkup($header, index) {
    const $span = $header.querySelector(`.${this.sectionButtonClass}`);
    const $heading = $header.querySelector(`.${this.sectionHeadingClass}`);
    const $summary = $header.querySelector(`.${this.sectionSummaryClass}`);
    if (!$heading) {
      throw new ElementError({
        componentName: "Accordion",
        identifier: `Section heading (\`.${this.sectionHeadingClass}\`)`
      });
    }
    if (!$span) {
      throw new ElementError({
        componentName: "Accordion",
        identifier: `Section button placeholder (\`<span class="${this.sectionButtonClass}">\`)`
      });
    }
    const $button = document.createElement("button");
    $button.setAttribute("type", "button");
    $button.setAttribute("aria-controls", `${this.$module.id}-content-${index + 1}`);
    for (const attr of Array.from($span.attributes)) {
      if (attr.nodeName !== "id") {
        $button.setAttribute(attr.nodeName, `${attr.nodeValue}`);
      }
    }
    const $headingText = document.createElement("span");
    $headingText.classList.add(this.sectionHeadingTextClass);
    $headingText.id = $span.id;
    const $headingTextFocus = document.createElement("span");
    $headingTextFocus.classList.add(this.sectionHeadingTextFocusClass);
    $headingText.appendChild($headingTextFocus);
    $headingTextFocus.innerHTML = $span.innerHTML;
    const $showHideToggle = document.createElement("span");
    $showHideToggle.classList.add(this.sectionShowHideToggleClass);
    $showHideToggle.setAttribute("data-nosnippet", "");
    const $showHideToggleFocus = document.createElement("span");
    $showHideToggleFocus.classList.add(this.sectionShowHideToggleFocusClass);
    $showHideToggle.appendChild($showHideToggleFocus);
    const $showHideText = document.createElement("span");
    const $showHideIcon = document.createElement("span");
    $showHideIcon.classList.add(this.upChevronIconClass);
    $showHideToggleFocus.appendChild($showHideIcon);
    $showHideText.classList.add(this.sectionShowHideTextClass);
    $showHideToggleFocus.appendChild($showHideText);
    $button.appendChild($headingText);
    $button.appendChild(this.getButtonPunctuationEl());
    if ($summary != null && $summary.parentNode) {
      const $summarySpan = document.createElement("span");
      const $summarySpanFocus = document.createElement("span");
      $summarySpanFocus.classList.add(this.sectionSummaryFocusClass);
      $summarySpan.appendChild($summarySpanFocus);
      for (const attr of Array.from($summary.attributes)) {
        $summarySpan.setAttribute(attr.nodeName, `${attr.nodeValue}`);
      }
      $summarySpanFocus.innerHTML = $summary.innerHTML;
      $summary.parentNode.replaceChild($summarySpan, $summary);
      $button.appendChild($summarySpan);
      $button.appendChild(this.getButtonPunctuationEl());
    }
    $button.appendChild($showHideToggle);
    $heading.removeChild($span);
    $heading.appendChild($button);
  }
  onBeforeMatch(event) {
    const $fragment = event.target;
    if (!($fragment instanceof Element)) {
      return;
    }
    const $section = $fragment.closest(`.${this.sectionClass}`);
    if ($section) {
      this.setExpanded(true, $section);
    }
  }
  onSectionToggle($section) {
    const expanded = this.isExpanded($section);
    this.setExpanded(!expanded, $section);
    this.storeState($section);
  }
  onShowOrHideAllToggle() {
    const nowExpanded = !this.checkIfAllSectionsOpen();
    this.$sections.forEach(($section) => {
      this.setExpanded(nowExpanded, $section);
      this.storeState($section);
    });
    this.updateShowAllButton(nowExpanded);
  }
  setExpanded(expanded, $section) {
    const $showHideIcon = $section.querySelector(`.${this.upChevronIconClass}`);
    const $showHideText = $section.querySelector(`.${this.sectionShowHideTextClass}`);
    const $button = $section.querySelector(`.${this.sectionButtonClass}`);
    const $content = $section.querySelector(`.${this.sectionContentClass}`);
    if (!$content) {
      throw new ElementError({
        componentName: "Accordion",
        identifier: `Section content (\`<div class="${this.sectionContentClass}">\`)`
      });
    }
    if (!$showHideIcon || !$showHideText || !$button) {
      return;
    }
    const newButtonText = expanded ? this.i18n.t("hideSection") : this.i18n.t("showSection");
    $showHideText.textContent = newButtonText;
    $button.setAttribute("aria-expanded", `${expanded}`);
    const ariaLabelParts = [];
    const $headingText = $section.querySelector(`.${this.sectionHeadingTextClass}`);
    if ($headingText) {
      ariaLabelParts.push(`${$headingText.textContent}`.trim());
    }
    const $summary = $section.querySelector(`.${this.sectionSummaryClass}`);
    if ($summary) {
      ariaLabelParts.push(`${$summary.textContent}`.trim());
    }
    const ariaLabelMessage = expanded ? this.i18n.t("hideSectionAriaLabel") : this.i18n.t("showSectionAriaLabel");
    ariaLabelParts.push(ariaLabelMessage);
    $button.setAttribute("aria-label", ariaLabelParts.join(" , "));
    if (expanded) {
      $content.removeAttribute("hidden");
      $section.classList.add(this.sectionExpandedClass);
      $showHideIcon.classList.remove(this.downChevronIconClass);
    } else {
      $content.setAttribute("hidden", "until-found");
      $section.classList.remove(this.sectionExpandedClass);
      $showHideIcon.classList.add(this.downChevronIconClass);
    }
    const areAllSectionsOpen = this.checkIfAllSectionsOpen();
    this.updateShowAllButton(areAllSectionsOpen);
  }
  isExpanded($section) {
    return $section.classList.contains(this.sectionExpandedClass);
  }
  checkIfAllSectionsOpen() {
    const sectionsCount = this.$sections.length;
    const expandedSectionCount = this.$module.querySelectorAll(`.${this.sectionExpandedClass}`).length;
    const areAllSectionsOpen = sectionsCount === expandedSectionCount;
    return areAllSectionsOpen;
  }
  updateShowAllButton(expanded) {
    if (!this.$showAllButton || !this.$showAllText || !this.$showAllIcon) {
      return;
    }
    this.$showAllButton.setAttribute("aria-expanded", expanded.toString());
    this.$showAllText.textContent = expanded ? this.i18n.t("hideAllSections") : this.i18n.t("showAllSections");
    this.$showAllIcon.classList.toggle(this.downChevronIconClass, !expanded);
  }
  storeState($section) {
    if (this.browserSupportsSessionStorage && this.config.rememberExpanded) {
      const $button = $section.querySelector(`.${this.sectionButtonClass}`);
      if ($button) {
        const contentId = $button.getAttribute("aria-controls");
        const contentState = $button.getAttribute("aria-expanded");
        if (contentId && contentState) {
          window.sessionStorage.setItem(contentId, contentState);
        }
      }
    }
  }
  setInitialState($section) {
    if (this.browserSupportsSessionStorage && this.config.rememberExpanded) {
      const $button = $section.querySelector(`.${this.sectionButtonClass}`);
      if ($button) {
        const contentId = $button.getAttribute("aria-controls");
        const contentState = contentId ? window.sessionStorage.getItem(contentId) : null;
        if (contentState !== null) {
          this.setExpanded(contentState === "true", $section);
        }
      }
    }
  }
  getButtonPunctuationEl() {
    const $punctuationEl = document.createElement("span");
    $punctuationEl.classList.add("govuk-visually-hidden", this.sectionHeadingDividerClass);
    $punctuationEl.innerHTML = ", ";
    return $punctuationEl;
  }
};
Accordion.moduleName = "govuk-accordion";
Accordion.defaults = Object.freeze({
  i18n: {
    hideAllSections: "Hide all sections",
    hideSection: "Hide",
    hideSectionAriaLabel: "Hide this section",
    showAllSections: "Show all sections",
    showSection: "Show",
    showSectionAriaLabel: "Show this section"
  },
  rememberExpanded: true
});
var helper = {
  /**
   * Check for `window.sessionStorage`, and that it actually works.
   *
   * @returns {boolean} True if session storage is available
   */
  checkForSessionStorage: function() {
    const testString = "this is the test string";
    let result;
    try {
      window.sessionStorage.setItem(testString, testString);
      result = window.sessionStorage.getItem(testString) === testString.toString();
      window.sessionStorage.removeItem(testString);
      return result;
    } catch (exception) {
      return false;
    }
  }
};

// node_modules/govuk-frontend/dist/govuk/components/button/button.mjs
var KEY_SPACE = 32;
var DEBOUNCE_TIMEOUT_IN_SECONDS = 1;
var Button = class _Button extends GOVUKFrontendComponent {
  /**
   * @param {Element | null} $module - HTML element to use for button
   * @param {ButtonConfig} [config] - Button config
   */
  constructor($module, config = {}) {
    super();
    this.$module = void 0;
    this.config = void 0;
    this.debounceFormSubmitTimer = null;
    if (!($module instanceof HTMLElement)) {
      throw new ElementError({
        componentName: "Button",
        element: $module,
        identifier: "Root element (`$module`)"
      });
    }
    this.$module = $module;
    this.config = mergeConfigs(_Button.defaults, config, normaliseDataset($module.dataset));
    this.$module.addEventListener("keydown", (event) => this.handleKeyDown(event));
    this.$module.addEventListener("click", (event) => this.debounce(event));
  }
  handleKeyDown(event) {
    const $target = event.target;
    if (event.keyCode !== KEY_SPACE) {
      return;
    }
    if ($target instanceof HTMLElement && $target.getAttribute("role") === "button") {
      event.preventDefault();
      $target.click();
    }
  }
  debounce(event) {
    if (!this.config.preventDoubleClick) {
      return;
    }
    if (this.debounceFormSubmitTimer) {
      event.preventDefault();
      return false;
    }
    this.debounceFormSubmitTimer = window.setTimeout(() => {
      this.debounceFormSubmitTimer = null;
    }, DEBOUNCE_TIMEOUT_IN_SECONDS * 1e3);
  }
};
Button.moduleName = "govuk-button";
Button.defaults = Object.freeze({
  preventDoubleClick: false
});

// node_modules/govuk-frontend/dist/govuk/common/closest-attribute-value.mjs
function closestAttributeValue($element, attributeName) {
  const $closestElementWithAttribute = $element.closest(`[${attributeName}]`);
  return $closestElementWithAttribute ? $closestElementWithAttribute.getAttribute(attributeName) : null;
}

// node_modules/govuk-frontend/dist/govuk/components/character-count/character-count.mjs
var CharacterCount = class _CharacterCount extends GOVUKFrontendComponent {
  /**
   * @param {Element | null} $module - HTML element to use for character count
   * @param {CharacterCountConfig} [config] - Character count config
   */
  constructor($module, config = {}) {
    var _ref, _this$config$maxwords;
    super();
    this.$module = void 0;
    this.$textarea = void 0;
    this.$visibleCountMessage = void 0;
    this.$screenReaderCountMessage = void 0;
    this.lastInputTimestamp = null;
    this.lastInputValue = "";
    this.valueChecker = null;
    this.config = void 0;
    this.i18n = void 0;
    this.maxLength = void 0;
    if (!($module instanceof HTMLElement)) {
      throw new ElementError({
        componentName: "Character count",
        element: $module,
        identifier: "Root element (`$module`)"
      });
    }
    const $textarea = $module.querySelector(".govuk-js-character-count");
    if (!($textarea instanceof HTMLTextAreaElement || $textarea instanceof HTMLInputElement)) {
      throw new ElementError({
        componentName: "Character count",
        element: $textarea,
        expectedType: "HTMLTextareaElement or HTMLInputElement",
        identifier: "Form field (`.govuk-js-character-count`)"
      });
    }
    const datasetConfig = normaliseDataset($module.dataset);
    let configOverrides = {};
    if ("maxwords" in datasetConfig || "maxlength" in datasetConfig) {
      configOverrides = {
        maxlength: void 0,
        maxwords: void 0
      };
    }
    this.config = mergeConfigs(_CharacterCount.defaults, config, configOverrides, datasetConfig);
    const errors = validateConfig(_CharacterCount.schema, this.config);
    if (errors[0]) {
      throw new ConfigError(`Character count: ${errors[0]}`);
    }
    this.i18n = new I18n(extractConfigByNamespace(this.config, "i18n"), {
      locale: closestAttributeValue($module, "lang")
    });
    this.maxLength = (_ref = (_this$config$maxwords = this.config.maxwords) != null ? _this$config$maxwords : this.config.maxlength) != null ? _ref : Infinity;
    this.$module = $module;
    this.$textarea = $textarea;
    const textareaDescriptionId = `${this.$textarea.id}-info`;
    const $textareaDescription = document.getElementById(textareaDescriptionId);
    if (!$textareaDescription) {
      throw new ElementError({
        componentName: "Character count",
        element: $textareaDescription,
        identifier: `Count message (\`id="${textareaDescriptionId}"\`)`
      });
    }
    if (`${$textareaDescription.textContent}`.match(/^\s*$/)) {
      $textareaDescription.textContent = this.i18n.t("textareaDescription", {
        count: this.maxLength
      });
    }
    this.$textarea.insertAdjacentElement("afterend", $textareaDescription);
    const $screenReaderCountMessage = document.createElement("div");
    $screenReaderCountMessage.className = "govuk-character-count__sr-status govuk-visually-hidden";
    $screenReaderCountMessage.setAttribute("aria-live", "polite");
    this.$screenReaderCountMessage = $screenReaderCountMessage;
    $textareaDescription.insertAdjacentElement("afterend", $screenReaderCountMessage);
    const $visibleCountMessage = document.createElement("div");
    $visibleCountMessage.className = $textareaDescription.className;
    $visibleCountMessage.classList.add("govuk-character-count__status");
    $visibleCountMessage.setAttribute("aria-hidden", "true");
    this.$visibleCountMessage = $visibleCountMessage;
    $textareaDescription.insertAdjacentElement("afterend", $visibleCountMessage);
    $textareaDescription.classList.add("govuk-visually-hidden");
    this.$textarea.removeAttribute("maxlength");
    this.bindChangeEvents();
    window.addEventListener("pageshow", () => this.updateCountMessage());
    this.updateCountMessage();
  }
  bindChangeEvents() {
    this.$textarea.addEventListener("keyup", () => this.handleKeyUp());
    this.$textarea.addEventListener("focus", () => this.handleFocus());
    this.$textarea.addEventListener("blur", () => this.handleBlur());
  }
  handleKeyUp() {
    this.updateVisibleCountMessage();
    this.lastInputTimestamp = Date.now();
  }
  handleFocus() {
    this.valueChecker = window.setInterval(() => {
      if (!this.lastInputTimestamp || Date.now() - 500 >= this.lastInputTimestamp) {
        this.updateIfValueChanged();
      }
    }, 1e3);
  }
  handleBlur() {
    if (this.valueChecker) {
      window.clearInterval(this.valueChecker);
    }
  }
  updateIfValueChanged() {
    if (this.$textarea.value !== this.lastInputValue) {
      this.lastInputValue = this.$textarea.value;
      this.updateCountMessage();
    }
  }
  updateCountMessage() {
    this.updateVisibleCountMessage();
    this.updateScreenReaderCountMessage();
  }
  updateVisibleCountMessage() {
    const remainingNumber = this.maxLength - this.count(this.$textarea.value);
    const isError = remainingNumber < 0;
    this.$visibleCountMessage.classList.toggle("govuk-character-count__message--disabled", !this.isOverThreshold());
    this.$textarea.classList.toggle("govuk-textarea--error", isError);
    this.$visibleCountMessage.classList.toggle("govuk-error-message", isError);
    this.$visibleCountMessage.classList.toggle("govuk-hint", !isError);
    this.$visibleCountMessage.textContent = this.getCountMessage();
  }
  updateScreenReaderCountMessage() {
    if (this.isOverThreshold()) {
      this.$screenReaderCountMessage.removeAttribute("aria-hidden");
    } else {
      this.$screenReaderCountMessage.setAttribute("aria-hidden", "true");
    }
    this.$screenReaderCountMessage.textContent = this.getCountMessage();
  }
  count(text) {
    if (this.config.maxwords) {
      var _text$match;
      const tokens = (_text$match = text.match(/\S+/g)) != null ? _text$match : [];
      return tokens.length;
    }
    return text.length;
  }
  getCountMessage() {
    const remainingNumber = this.maxLength - this.count(this.$textarea.value);
    const countType = this.config.maxwords ? "words" : "characters";
    return this.formatCountMessage(remainingNumber, countType);
  }
  formatCountMessage(remainingNumber, countType) {
    if (remainingNumber === 0) {
      return this.i18n.t(`${countType}AtLimit`);
    }
    const translationKeySuffix = remainingNumber < 0 ? "OverLimit" : "UnderLimit";
    return this.i18n.t(`${countType}${translationKeySuffix}`, {
      count: Math.abs(remainingNumber)
    });
  }
  isOverThreshold() {
    if (!this.config.threshold) {
      return true;
    }
    const currentLength = this.count(this.$textarea.value);
    const maxLength = this.maxLength;
    const thresholdValue = maxLength * this.config.threshold / 100;
    return thresholdValue <= currentLength;
  }
};
CharacterCount.moduleName = "govuk-character-count";
CharacterCount.defaults = Object.freeze({
  threshold: 0,
  i18n: {
    charactersUnderLimit: {
      one: "You have %{count} character remaining",
      other: "You have %{count} characters remaining"
    },
    charactersAtLimit: "You have 0 characters remaining",
    charactersOverLimit: {
      one: "You have %{count} character too many",
      other: "You have %{count} characters too many"
    },
    wordsUnderLimit: {
      one: "You have %{count} word remaining",
      other: "You have %{count} words remaining"
    },
    wordsAtLimit: "You have 0 words remaining",
    wordsOverLimit: {
      one: "You have %{count} word too many",
      other: "You have %{count} words too many"
    },
    textareaDescription: {
      other: ""
    }
  }
});
CharacterCount.schema = Object.freeze({
  anyOf: [{
    required: ["maxwords"],
    errorMessage: 'Either "maxlength" or "maxwords" must be provided'
  }, {
    required: ["maxlength"],
    errorMessage: 'Either "maxlength" or "maxwords" must be provided'
  }]
});

// node_modules/govuk-frontend/dist/govuk/components/checkboxes/checkboxes.mjs
var Checkboxes = class extends GOVUKFrontendComponent {
  /**
   * Checkboxes can be associated with a 'conditionally revealed' content block
   * – for example, a checkbox for 'Phone' could reveal an additional form field
   * for the user to enter their phone number.
   *
   * These associations are made using a `data-aria-controls` attribute, which
   * is promoted to an aria-controls attribute during initialisation.
   *
   * We also need to restore the state of any conditional reveals on the page
   * (for example if the user has navigated back), and set up event handlers to
   * keep the reveal in sync with the checkbox state.
   *
   * @param {Element | null} $module - HTML element to use for checkboxes
   */
  constructor($module) {
    super();
    this.$module = void 0;
    this.$inputs = void 0;
    if (!($module instanceof HTMLElement)) {
      throw new ElementError({
        componentName: "Checkboxes",
        element: $module,
        identifier: "Root element (`$module`)"
      });
    }
    const $inputs = $module.querySelectorAll('input[type="checkbox"]');
    if (!$inputs.length) {
      throw new ElementError({
        componentName: "Checkboxes",
        identifier: 'Form inputs (`<input type="checkbox">`)'
      });
    }
    this.$module = $module;
    this.$inputs = $inputs;
    this.$inputs.forEach(($input) => {
      const targetId = $input.getAttribute("data-aria-controls");
      if (!targetId) {
        return;
      }
      if (!document.getElementById(targetId)) {
        throw new ElementError({
          componentName: "Checkboxes",
          identifier: `Conditional reveal (\`id="${targetId}"\`)`
        });
      }
      $input.setAttribute("aria-controls", targetId);
      $input.removeAttribute("data-aria-controls");
    });
    window.addEventListener("pageshow", () => this.syncAllConditionalReveals());
    this.syncAllConditionalReveals();
    this.$module.addEventListener("click", (event) => this.handleClick(event));
  }
  syncAllConditionalReveals() {
    this.$inputs.forEach(($input) => this.syncConditionalRevealWithInputState($input));
  }
  syncConditionalRevealWithInputState($input) {
    const targetId = $input.getAttribute("aria-controls");
    if (!targetId) {
      return;
    }
    const $target = document.getElementById(targetId);
    if ($target && $target.classList.contains("govuk-checkboxes__conditional")) {
      const inputIsChecked = $input.checked;
      $input.setAttribute("aria-expanded", inputIsChecked.toString());
      $target.classList.toggle("govuk-checkboxes__conditional--hidden", !inputIsChecked);
    }
  }
  unCheckAllInputsExcept($input) {
    const allInputsWithSameName = document.querySelectorAll(`input[type="checkbox"][name="${$input.name}"]`);
    allInputsWithSameName.forEach(($inputWithSameName) => {
      const hasSameFormOwner = $input.form === $inputWithSameName.form;
      if (hasSameFormOwner && $inputWithSameName !== $input) {
        $inputWithSameName.checked = false;
        this.syncConditionalRevealWithInputState($inputWithSameName);
      }
    });
  }
  unCheckExclusiveInputs($input) {
    const allInputsWithSameNameAndExclusiveBehaviour = document.querySelectorAll(`input[data-behaviour="exclusive"][type="checkbox"][name="${$input.name}"]`);
    allInputsWithSameNameAndExclusiveBehaviour.forEach(($exclusiveInput) => {
      const hasSameFormOwner = $input.form === $exclusiveInput.form;
      if (hasSameFormOwner) {
        $exclusiveInput.checked = false;
        this.syncConditionalRevealWithInputState($exclusiveInput);
      }
    });
  }
  handleClick(event) {
    const $clickedInput = event.target;
    if (!($clickedInput instanceof HTMLInputElement) || $clickedInput.type !== "checkbox") {
      return;
    }
    const hasAriaControls = $clickedInput.getAttribute("aria-controls");
    if (hasAriaControls) {
      this.syncConditionalRevealWithInputState($clickedInput);
    }
    if (!$clickedInput.checked) {
      return;
    }
    const hasBehaviourExclusive = $clickedInput.getAttribute("data-behaviour") === "exclusive";
    if (hasBehaviourExclusive) {
      this.unCheckAllInputsExcept($clickedInput);
    } else {
      this.unCheckExclusiveInputs($clickedInput);
    }
  }
};
Checkboxes.moduleName = "govuk-checkboxes";

// node_modules/govuk-frontend/dist/govuk/components/error-summary/error-summary.mjs
var ErrorSummary = class _ErrorSummary extends GOVUKFrontendComponent {
  /**
   * @param {Element | null} $module - HTML element to use for error summary
   * @param {ErrorSummaryConfig} [config] - Error summary config
   */
  constructor($module, config = {}) {
    super();
    this.$module = void 0;
    this.config = void 0;
    if (!($module instanceof HTMLElement)) {
      throw new ElementError({
        componentName: "Error summary",
        element: $module,
        identifier: "Root element (`$module`)"
      });
    }
    this.$module = $module;
    this.config = mergeConfigs(_ErrorSummary.defaults, config, normaliseDataset($module.dataset));
    if (!this.config.disableAutoFocus) {
      setFocus(this.$module);
    }
    this.$module.addEventListener("click", (event) => this.handleClick(event));
  }
  handleClick(event) {
    const $target = event.target;
    if ($target && this.focusTarget($target)) {
      event.preventDefault();
    }
  }
  focusTarget($target) {
    if (!($target instanceof HTMLAnchorElement)) {
      return false;
    }
    const inputId = getFragmentFromUrl($target.href);
    if (!inputId) {
      return false;
    }
    const $input = document.getElementById(inputId);
    if (!$input) {
      return false;
    }
    const $legendOrLabel = this.getAssociatedLegendOrLabel($input);
    if (!$legendOrLabel) {
      return false;
    }
    $legendOrLabel.scrollIntoView();
    $input.focus({
      preventScroll: true
    });
    return true;
  }
  getAssociatedLegendOrLabel($input) {
    var _document$querySelect;
    const $fieldset = $input.closest("fieldset");
    if ($fieldset) {
      const $legends = $fieldset.getElementsByTagName("legend");
      if ($legends.length) {
        const $candidateLegend = $legends[0];
        if ($input instanceof HTMLInputElement && ($input.type === "checkbox" || $input.type === "radio")) {
          return $candidateLegend;
        }
        const legendTop = $candidateLegend.getBoundingClientRect().top;
        const inputRect = $input.getBoundingClientRect();
        if (inputRect.height && window.innerHeight) {
          const inputBottom = inputRect.top + inputRect.height;
          if (inputBottom - legendTop < window.innerHeight / 2) {
            return $candidateLegend;
          }
        }
      }
    }
    return (_document$querySelect = document.querySelector(`label[for='${$input.getAttribute("id")}']`)) != null ? _document$querySelect : $input.closest("label");
  }
};
ErrorSummary.moduleName = "govuk-error-summary";
ErrorSummary.defaults = Object.freeze({
  disableAutoFocus: false
});

// node_modules/govuk-frontend/dist/govuk/components/exit-this-page/exit-this-page.mjs
var ExitThisPage = class _ExitThisPage extends GOVUKFrontendComponent {
  /**
   * @param {Element | null} $module - HTML element that wraps the Exit This Page button
   * @param {ExitThisPageConfig} [config] - Exit This Page config
   */
  constructor($module, config = {}) {
    super();
    this.$module = void 0;
    this.config = void 0;
    this.i18n = void 0;
    this.$button = void 0;
    this.$skiplinkButton = null;
    this.$updateSpan = null;
    this.$indicatorContainer = null;
    this.$overlay = null;
    this.keypressCounter = 0;
    this.lastKeyWasModified = false;
    this.timeoutTime = 5e3;
    this.keypressTimeoutId = null;
    this.timeoutMessageId = null;
    if (!($module instanceof HTMLElement)) {
      throw new ElementError({
        componentName: "Exit this page",
        element: $module,
        identifier: "Root element (`$module`)"
      });
    }
    const $button = $module.querySelector(".govuk-exit-this-page__button");
    if (!($button instanceof HTMLAnchorElement)) {
      throw new ElementError({
        componentName: "Exit this page",
        element: $button,
        expectedType: "HTMLAnchorElement",
        identifier: "Button (`.govuk-exit-this-page__button`)"
      });
    }
    this.config = mergeConfigs(_ExitThisPage.defaults, config, normaliseDataset($module.dataset));
    this.i18n = new I18n(extractConfigByNamespace(this.config, "i18n"));
    this.$module = $module;
    this.$button = $button;
    const $skiplinkButton = document.querySelector(".govuk-js-exit-this-page-skiplink");
    if ($skiplinkButton instanceof HTMLAnchorElement) {
      this.$skiplinkButton = $skiplinkButton;
    }
    this.buildIndicator();
    this.initUpdateSpan();
    this.initButtonClickHandler();
    if (!("govukFrontendExitThisPageKeypress" in document.body.dataset)) {
      document.addEventListener("keyup", this.handleKeypress.bind(this), true);
      document.body.dataset.govukFrontendExitThisPageKeypress = "true";
    }
    window.addEventListener("pageshow", this.resetPage.bind(this));
  }
  initUpdateSpan() {
    this.$updateSpan = document.createElement("span");
    this.$updateSpan.setAttribute("role", "status");
    this.$updateSpan.className = "govuk-visually-hidden";
    this.$module.appendChild(this.$updateSpan);
  }
  initButtonClickHandler() {
    this.$button.addEventListener("click", this.handleClick.bind(this));
    if (this.$skiplinkButton) {
      this.$skiplinkButton.addEventListener("click", this.handleClick.bind(this));
    }
  }
  buildIndicator() {
    this.$indicatorContainer = document.createElement("div");
    this.$indicatorContainer.className = "govuk-exit-this-page__indicator";
    this.$indicatorContainer.setAttribute("aria-hidden", "true");
    for (let i = 0; i < 3; i++) {
      const $indicator = document.createElement("div");
      $indicator.className = "govuk-exit-this-page__indicator-light";
      this.$indicatorContainer.appendChild($indicator);
    }
    this.$button.appendChild(this.$indicatorContainer);
  }
  updateIndicator() {
    if (!this.$indicatorContainer) {
      return;
    }
    this.$indicatorContainer.classList.toggle("govuk-exit-this-page__indicator--visible", this.keypressCounter > 0);
    const $indicators = this.$indicatorContainer.querySelectorAll(".govuk-exit-this-page__indicator-light");
    $indicators.forEach(($indicator, index) => {
      $indicator.classList.toggle("govuk-exit-this-page__indicator-light--on", index < this.keypressCounter);
    });
  }
  exitPage() {
    if (!this.$updateSpan) {
      return;
    }
    this.$updateSpan.textContent = "";
    document.body.classList.add("govuk-exit-this-page-hide-content");
    this.$overlay = document.createElement("div");
    this.$overlay.className = "govuk-exit-this-page-overlay";
    this.$overlay.setAttribute("role", "alert");
    document.body.appendChild(this.$overlay);
    this.$overlay.textContent = this.i18n.t("activated");
    window.location.href = this.$button.href;
  }
  handleClick(event) {
    event.preventDefault();
    this.exitPage();
  }
  handleKeypress(event) {
    if (!this.$updateSpan) {
      return;
    }
    if ((event.key === "Shift" || event.keyCode === 16 || event.which === 16) && !this.lastKeyWasModified) {
      this.keypressCounter += 1;
      this.updateIndicator();
      if (this.timeoutMessageId) {
        window.clearTimeout(this.timeoutMessageId);
        this.timeoutMessageId = null;
      }
      if (this.keypressCounter >= 3) {
        this.keypressCounter = 0;
        if (this.keypressTimeoutId) {
          window.clearTimeout(this.keypressTimeoutId);
          this.keypressTimeoutId = null;
        }
        this.exitPage();
      } else {
        if (this.keypressCounter === 1) {
          this.$updateSpan.textContent = this.i18n.t("pressTwoMoreTimes");
        } else {
          this.$updateSpan.textContent = this.i18n.t("pressOneMoreTime");
        }
      }
      this.setKeypressTimer();
    } else if (this.keypressTimeoutId) {
      this.resetKeypressTimer();
    }
    this.lastKeyWasModified = event.shiftKey;
  }
  setKeypressTimer() {
    if (this.keypressTimeoutId) {
      window.clearTimeout(this.keypressTimeoutId);
    }
    this.keypressTimeoutId = window.setTimeout(this.resetKeypressTimer.bind(this), this.timeoutTime);
  }
  resetKeypressTimer() {
    if (!this.$updateSpan) {
      return;
    }
    if (this.keypressTimeoutId) {
      window.clearTimeout(this.keypressTimeoutId);
      this.keypressTimeoutId = null;
    }
    const $updateSpan = this.$updateSpan;
    this.keypressCounter = 0;
    $updateSpan.textContent = this.i18n.t("timedOut");
    this.timeoutMessageId = window.setTimeout(() => {
      $updateSpan.textContent = "";
    }, this.timeoutTime);
    this.updateIndicator();
  }
  resetPage() {
    document.body.classList.remove("govuk-exit-this-page-hide-content");
    if (this.$overlay) {
      this.$overlay.remove();
      this.$overlay = null;
    }
    if (this.$updateSpan) {
      this.$updateSpan.setAttribute("role", "status");
      this.$updateSpan.textContent = "";
    }
    this.updateIndicator();
    if (this.keypressTimeoutId) {
      window.clearTimeout(this.keypressTimeoutId);
    }
    if (this.timeoutMessageId) {
      window.clearTimeout(this.timeoutMessageId);
    }
  }
};
ExitThisPage.moduleName = "govuk-exit-this-page";
ExitThisPage.defaults = Object.freeze({
  i18n: {
    activated: "Loading.",
    timedOut: "Exit this page expired.",
    pressTwoMoreTimes: "Shift, press 2 more times to exit.",
    pressOneMoreTime: "Shift, press 1 more time to exit."
  }
});

// node_modules/govuk-frontend/dist/govuk/components/header/header.mjs
var Header = class extends GOVUKFrontendComponent {
  /**
   * Apply a matchMedia for desktop which will trigger a state sync if the
   * browser viewport moves between states.
   *
   * @param {Element | null} $module - HTML element to use for header
   */
  constructor($module) {
    super();
    this.$module = void 0;
    this.$menuButton = void 0;
    this.$menu = void 0;
    this.menuIsOpen = false;
    this.mql = null;
    if (!$module) {
      throw new ElementError({
        componentName: "Header",
        element: $module,
        identifier: "Root element (`$module`)"
      });
    }
    this.$module = $module;
    const $menuButton = $module.querySelector(".govuk-js-header-toggle");
    if (!$menuButton) {
      return this;
    }
    const menuId = $menuButton.getAttribute("aria-controls");
    if (!menuId) {
      throw new ElementError({
        componentName: "Header",
        identifier: 'Navigation button (`<button class="govuk-js-header-toggle">`) attribute (`aria-controls`)'
      });
    }
    const $menu = document.getElementById(menuId);
    if (!$menu) {
      throw new ElementError({
        componentName: "Header",
        element: $menu,
        identifier: `Navigation (\`<ul id="${menuId}">\`)`
      });
    }
    this.$menu = $menu;
    this.$menuButton = $menuButton;
    this.setupResponsiveChecks();
    this.$menuButton.addEventListener("click", () => this.handleMenuButtonClick());
  }
  setupResponsiveChecks() {
    const breakpoint = getBreakpoint("desktop");
    if (!breakpoint.value) {
      throw new ElementError({
        componentName: "Header",
        identifier: `CSS custom property (\`${breakpoint.property}\`) on pseudo-class \`:root\``
      });
    }
    this.mql = window.matchMedia(`(min-width: ${breakpoint.value})`);
    if ("addEventListener" in this.mql) {
      this.mql.addEventListener("change", () => this.checkMode());
    } else {
      this.mql.addListener(() => this.checkMode());
    }
    this.checkMode();
  }
  checkMode() {
    if (!this.mql || !this.$menu || !this.$menuButton) {
      return;
    }
    if (this.mql.matches) {
      this.$menu.removeAttribute("hidden");
      this.$menuButton.setAttribute("hidden", "");
    } else {
      this.$menuButton.removeAttribute("hidden");
      this.$menuButton.setAttribute("aria-expanded", this.menuIsOpen.toString());
      if (this.menuIsOpen) {
        this.$menu.removeAttribute("hidden");
      } else {
        this.$menu.setAttribute("hidden", "");
      }
    }
  }
  handleMenuButtonClick() {
    this.menuIsOpen = !this.menuIsOpen;
    this.checkMode();
  }
};
Header.moduleName = "govuk-header";

// node_modules/govuk-frontend/dist/govuk/components/notification-banner/notification-banner.mjs
var NotificationBanner = class _NotificationBanner extends GOVUKFrontendComponent {
  /**
   * @param {Element | null} $module - HTML element to use for notification banner
   * @param {NotificationBannerConfig} [config] - Notification banner config
   */
  constructor($module, config = {}) {
    super();
    this.$module = void 0;
    this.config = void 0;
    if (!($module instanceof HTMLElement)) {
      throw new ElementError({
        componentName: "Notification banner",
        element: $module,
        identifier: "Root element (`$module`)"
      });
    }
    this.$module = $module;
    this.config = mergeConfigs(_NotificationBanner.defaults, config, normaliseDataset($module.dataset));
    if (this.$module.getAttribute("role") === "alert" && !this.config.disableAutoFocus) {
      setFocus(this.$module);
    }
  }
};
NotificationBanner.moduleName = "govuk-notification-banner";
NotificationBanner.defaults = Object.freeze({
  disableAutoFocus: false
});

// node_modules/govuk-frontend/dist/govuk/components/radios/radios.mjs
var Radios = class extends GOVUKFrontendComponent {
  /**
   * Radios can be associated with a 'conditionally revealed' content block –
   * for example, a radio for 'Phone' could reveal an additional form field for
   * the user to enter their phone number.
   *
   * These associations are made using a `data-aria-controls` attribute, which
   * is promoted to an aria-controls attribute during initialisation.
   *
   * We also need to restore the state of any conditional reveals on the page
   * (for example if the user has navigated back), and set up event handlers to
   * keep the reveal in sync with the radio state.
   *
   * @param {Element | null} $module - HTML element to use for radios
   */
  constructor($module) {
    super();
    this.$module = void 0;
    this.$inputs = void 0;
    if (!($module instanceof HTMLElement)) {
      throw new ElementError({
        componentName: "Radios",
        element: $module,
        identifier: "Root element (`$module`)"
      });
    }
    const $inputs = $module.querySelectorAll('input[type="radio"]');
    if (!$inputs.length) {
      throw new ElementError({
        componentName: "Radios",
        identifier: 'Form inputs (`<input type="radio">`)'
      });
    }
    this.$module = $module;
    this.$inputs = $inputs;
    this.$inputs.forEach(($input) => {
      const targetId = $input.getAttribute("data-aria-controls");
      if (!targetId) {
        return;
      }
      if (!document.getElementById(targetId)) {
        throw new ElementError({
          componentName: "Radios",
          identifier: `Conditional reveal (\`id="${targetId}"\`)`
        });
      }
      $input.setAttribute("aria-controls", targetId);
      $input.removeAttribute("data-aria-controls");
    });
    window.addEventListener("pageshow", () => this.syncAllConditionalReveals());
    this.syncAllConditionalReveals();
    this.$module.addEventListener("click", (event) => this.handleClick(event));
  }
  syncAllConditionalReveals() {
    this.$inputs.forEach(($input) => this.syncConditionalRevealWithInputState($input));
  }
  syncConditionalRevealWithInputState($input) {
    const targetId = $input.getAttribute("aria-controls");
    if (!targetId) {
      return;
    }
    const $target = document.getElementById(targetId);
    if ($target != null && $target.classList.contains("govuk-radios__conditional")) {
      const inputIsChecked = $input.checked;
      $input.setAttribute("aria-expanded", inputIsChecked.toString());
      $target.classList.toggle("govuk-radios__conditional--hidden", !inputIsChecked);
    }
  }
  handleClick(event) {
    const $clickedInput = event.target;
    if (!($clickedInput instanceof HTMLInputElement) || $clickedInput.type !== "radio") {
      return;
    }
    const $allInputs = document.querySelectorAll('input[type="radio"][aria-controls]');
    const $clickedInputForm = $clickedInput.form;
    const $clickedInputName = $clickedInput.name;
    $allInputs.forEach(($input) => {
      const hasSameFormOwner = $input.form === $clickedInputForm;
      const hasSameName = $input.name === $clickedInputName;
      if (hasSameName && hasSameFormOwner) {
        this.syncConditionalRevealWithInputState($input);
      }
    });
  }
};
Radios.moduleName = "govuk-radios";

// node_modules/govuk-frontend/dist/govuk/components/skip-link/skip-link.mjs
var SkipLink = class extends GOVUKFrontendComponent {
  /**
   * @param {Element | null} $module - HTML element to use for skip link
   * @throws {ElementError} when $module is not set or the wrong type
   * @throws {ElementError} when $module.hash does not contain a hash
   * @throws {ElementError} when the linked element is missing or the wrong type
   */
  constructor($module) {
    var _this$$module$getAttr;
    super();
    this.$module = void 0;
    if (!($module instanceof HTMLAnchorElement)) {
      throw new ElementError({
        componentName: "Skip link",
        element: $module,
        expectedType: "HTMLAnchorElement",
        identifier: "Root element (`$module`)"
      });
    }
    this.$module = $module;
    const hash = this.$module.hash;
    const href = (_this$$module$getAttr = this.$module.getAttribute("href")) != null ? _this$$module$getAttr : "";
    let url;
    try {
      url = new window.URL(this.$module.href);
    } catch (error) {
      throw new ElementError(`Skip link: Target link (\`href="${href}"\`) is invalid`);
    }
    if (url.origin !== window.location.origin || url.pathname !== window.location.pathname) {
      return;
    }
    const linkedElementId = getFragmentFromUrl(hash);
    if (!linkedElementId) {
      throw new ElementError(`Skip link: Target link (\`href="${href}"\`) has no hash fragment`);
    }
    const $linkedElement = document.getElementById(linkedElementId);
    if (!$linkedElement) {
      throw new ElementError({
        componentName: "Skip link",
        element: $linkedElement,
        identifier: `Target content (\`id="${linkedElementId}"\`)`
      });
    }
    this.$module.addEventListener("click", () => setFocus($linkedElement, {
      onBeforeFocus() {
        $linkedElement.classList.add("govuk-skip-link-focused-element");
      },
      onBlur() {
        $linkedElement.classList.remove("govuk-skip-link-focused-element");
      }
    }));
  }
};
SkipLink.moduleName = "govuk-skip-link";

// node_modules/govuk-frontend/dist/govuk/components/tabs/tabs.mjs
var Tabs = class extends GOVUKFrontendComponent {
  /**
   * @param {Element | null} $module - HTML element to use for tabs
   */
  constructor($module) {
    super();
    this.$module = void 0;
    this.$tabs = void 0;
    this.$tabList = void 0;
    this.$tabListItems = void 0;
    this.keys = {
      left: 37,
      right: 39,
      up: 38,
      down: 40
    };
    this.jsHiddenClass = "govuk-tabs__panel--hidden";
    this.changingHash = false;
    this.boundTabClick = void 0;
    this.boundTabKeydown = void 0;
    this.boundOnHashChange = void 0;
    this.mql = null;
    if (!$module) {
      throw new ElementError({
        componentName: "Tabs",
        element: $module,
        identifier: "Root element (`$module`)"
      });
    }
    const $tabs = $module.querySelectorAll("a.govuk-tabs__tab");
    if (!$tabs.length) {
      throw new ElementError({
        componentName: "Tabs",
        identifier: 'Links (`<a class="govuk-tabs__tab">`)'
      });
    }
    this.$module = $module;
    this.$tabs = $tabs;
    this.boundTabClick = this.onTabClick.bind(this);
    this.boundTabKeydown = this.onTabKeydown.bind(this);
    this.boundOnHashChange = this.onHashChange.bind(this);
    const $tabList = this.$module.querySelector(".govuk-tabs__list");
    const $tabListItems = this.$module.querySelectorAll("li.govuk-tabs__list-item");
    if (!$tabList) {
      throw new ElementError({
        componentName: "Tabs",
        identifier: 'List (`<ul class="govuk-tabs__list">`)'
      });
    }
    if (!$tabListItems.length) {
      throw new ElementError({
        componentName: "Tabs",
        identifier: 'List items (`<li class="govuk-tabs__list-item">`)'
      });
    }
    this.$tabList = $tabList;
    this.$tabListItems = $tabListItems;
    this.setupResponsiveChecks();
  }
  setupResponsiveChecks() {
    const breakpoint = getBreakpoint("tablet");
    if (!breakpoint.value) {
      throw new ElementError({
        componentName: "Tabs",
        identifier: `CSS custom property (\`${breakpoint.property}\`) on pseudo-class \`:root\``
      });
    }
    this.mql = window.matchMedia(`(min-width: ${breakpoint.value})`);
    if ("addEventListener" in this.mql) {
      this.mql.addEventListener("change", () => this.checkMode());
    } else {
      this.mql.addListener(() => this.checkMode());
    }
    this.checkMode();
  }
  checkMode() {
    var _this$mql;
    if ((_this$mql = this.mql) != null && _this$mql.matches) {
      this.setup();
    } else {
      this.teardown();
    }
  }
  setup() {
    var _this$getTab;
    this.$tabList.setAttribute("role", "tablist");
    this.$tabListItems.forEach(($item) => {
      $item.setAttribute("role", "presentation");
    });
    this.$tabs.forEach(($tab) => {
      this.setAttributes($tab);
      $tab.addEventListener("click", this.boundTabClick, true);
      $tab.addEventListener("keydown", this.boundTabKeydown, true);
      this.hideTab($tab);
    });
    const $activeTab = (_this$getTab = this.getTab(window.location.hash)) != null ? _this$getTab : this.$tabs[0];
    this.showTab($activeTab);
    window.addEventListener("hashchange", this.boundOnHashChange, true);
  }
  teardown() {
    this.$tabList.removeAttribute("role");
    this.$tabListItems.forEach(($item) => {
      $item.removeAttribute("role");
    });
    this.$tabs.forEach(($tab) => {
      $tab.removeEventListener("click", this.boundTabClick, true);
      $tab.removeEventListener("keydown", this.boundTabKeydown, true);
      this.unsetAttributes($tab);
    });
    window.removeEventListener("hashchange", this.boundOnHashChange, true);
  }
  onHashChange() {
    const hash = window.location.hash;
    const $tabWithHash = this.getTab(hash);
    if (!$tabWithHash) {
      return;
    }
    if (this.changingHash) {
      this.changingHash = false;
      return;
    }
    const $previousTab = this.getCurrentTab();
    if (!$previousTab) {
      return;
    }
    this.hideTab($previousTab);
    this.showTab($tabWithHash);
    $tabWithHash.focus();
  }
  hideTab($tab) {
    this.unhighlightTab($tab);
    this.hidePanel($tab);
  }
  showTab($tab) {
    this.highlightTab($tab);
    this.showPanel($tab);
  }
  getTab(hash) {
    return this.$module.querySelector(`a.govuk-tabs__tab[href="${hash}"]`);
  }
  setAttributes($tab) {
    const panelId = getFragmentFromUrl($tab.href);
    if (!panelId) {
      return;
    }
    $tab.setAttribute("id", `tab_${panelId}`);
    $tab.setAttribute("role", "tab");
    $tab.setAttribute("aria-controls", panelId);
    $tab.setAttribute("aria-selected", "false");
    $tab.setAttribute("tabindex", "-1");
    const $panel = this.getPanel($tab);
    if (!$panel) {
      return;
    }
    $panel.setAttribute("role", "tabpanel");
    $panel.setAttribute("aria-labelledby", $tab.id);
    $panel.classList.add(this.jsHiddenClass);
  }
  unsetAttributes($tab) {
    $tab.removeAttribute("id");
    $tab.removeAttribute("role");
    $tab.removeAttribute("aria-controls");
    $tab.removeAttribute("aria-selected");
    $tab.removeAttribute("tabindex");
    const $panel = this.getPanel($tab);
    if (!$panel) {
      return;
    }
    $panel.removeAttribute("role");
    $panel.removeAttribute("aria-labelledby");
    $panel.classList.remove(this.jsHiddenClass);
  }
  onTabClick(event) {
    const $currentTab = this.getCurrentTab();
    const $nextTab = event.currentTarget;
    if (!$currentTab || !($nextTab instanceof HTMLAnchorElement)) {
      return;
    }
    event.preventDefault();
    this.hideTab($currentTab);
    this.showTab($nextTab);
    this.createHistoryEntry($nextTab);
  }
  createHistoryEntry($tab) {
    const $panel = this.getPanel($tab);
    if (!$panel) {
      return;
    }
    const panelId = $panel.id;
    $panel.id = "";
    this.changingHash = true;
    window.location.hash = panelId;
    $panel.id = panelId;
  }
  onTabKeydown(event) {
    switch (event.keyCode) {
      case this.keys.left:
      case this.keys.up:
        this.activatePreviousTab();
        event.preventDefault();
        break;
      case this.keys.right:
      case this.keys.down:
        this.activateNextTab();
        event.preventDefault();
        break;
    }
  }
  activateNextTab() {
    const $currentTab = this.getCurrentTab();
    if (!($currentTab != null && $currentTab.parentElement)) {
      return;
    }
    const $nextTabListItem = $currentTab.parentElement.nextElementSibling;
    if (!$nextTabListItem) {
      return;
    }
    const $nextTab = $nextTabListItem.querySelector("a.govuk-tabs__tab");
    if (!$nextTab) {
      return;
    }
    this.hideTab($currentTab);
    this.showTab($nextTab);
    $nextTab.focus();
    this.createHistoryEntry($nextTab);
  }
  activatePreviousTab() {
    const $currentTab = this.getCurrentTab();
    if (!($currentTab != null && $currentTab.parentElement)) {
      return;
    }
    const $previousTabListItem = $currentTab.parentElement.previousElementSibling;
    if (!$previousTabListItem) {
      return;
    }
    const $previousTab = $previousTabListItem.querySelector("a.govuk-tabs__tab");
    if (!$previousTab) {
      return;
    }
    this.hideTab($currentTab);
    this.showTab($previousTab);
    $previousTab.focus();
    this.createHistoryEntry($previousTab);
  }
  getPanel($tab) {
    const panelId = getFragmentFromUrl($tab.href);
    if (!panelId) {
      return null;
    }
    return this.$module.querySelector(`#${panelId}`);
  }
  showPanel($tab) {
    const $panel = this.getPanel($tab);
    if (!$panel) {
      return;
    }
    $panel.classList.remove(this.jsHiddenClass);
  }
  hidePanel($tab) {
    const $panel = this.getPanel($tab);
    if (!$panel) {
      return;
    }
    $panel.classList.add(this.jsHiddenClass);
  }
  unhighlightTab($tab) {
    if (!$tab.parentElement) {
      return;
    }
    $tab.setAttribute("aria-selected", "false");
    $tab.parentElement.classList.remove("govuk-tabs__list-item--selected");
    $tab.setAttribute("tabindex", "-1");
  }
  highlightTab($tab) {
    if (!$tab.parentElement) {
      return;
    }
    $tab.setAttribute("aria-selected", "true");
    $tab.parentElement.classList.add("govuk-tabs__list-item--selected");
    $tab.setAttribute("tabindex", "0");
  }
  getCurrentTab() {
    return this.$module.querySelector(".govuk-tabs__list-item--selected a.govuk-tabs__tab");
  }
};
Tabs.moduleName = "govuk-tabs";

// node_modules/govuk-frontend/dist/govuk/all.mjs
function initAll(config) {
  var _config$scope;
  config = typeof config !== "undefined" ? config : {};
  if (!isSupported()) {
    console.log(new SupportError());
    return;
  }
  const components = [[Accordion, config.accordion], [Button, config.button], [CharacterCount, config.characterCount], [Checkboxes], [ErrorSummary, config.errorSummary], [ExitThisPage, config.exitThisPage], [Header], [NotificationBanner, config.notificationBanner], [Radios], [SkipLink], [Tabs]];
  const $scope = (_config$scope = config.scope) != null ? _config$scope : document;
  components.forEach(([Component, config2]) => {
    const $elements = $scope.querySelectorAll(`[data-module="${Component.moduleName}"]`);
    $elements.forEach(($element) => {
      try {
        "defaults" in Component ? new Component($element, config2) : new Component($element);
      } catch (error) {
        console.log(error);
      }
    });
  });
}

// app/javascript/application.js
initAll();
document.addEventListener("DOMContentLoaded", () => {
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
      inputFileUpload.addEventListener("change", (e) => {
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
        filters[idx].addEventListener("change", (e) => {
          e.target.form.submit();
        });
      }
    }
  }
  const inputFormSelect = document.getElementsByClassName("sau-form-select")[0];
  if (inputFormSelect) {
    const divOtherForm = document.getElementsByClassName("sau-other-form")[0];
    const divBudget = document.getElementsByClassName("sau-budget")[0];
    const divTaxAmount = document.getElementsByClassName("sau-tax-amount")[0];
    if (divOtherForm && divBudget && divTaxAmount) {
      let setDivs = function(value) {
        divOtherForm.style.display = value == "other" ? "block" : "none";
        divBudget.style.display = value == "tax" ? "none" : "block";
        divTaxAmount.style.display = value == "tax" ? "block" : "none";
      };
      setDivs(inputFormSelect.value);
      inputFormSelect.addEventListener("change", (e) => {
        setDivs(e.target.value);
      });
    }
  }
  const inputTaxSelect = document.getElementsByClassName("sau-tax-select")[0];
  if (inputTaxSelect) {
    const divTaxRange = document.getElementsByClassName("sau-tax-range")[0];
    if (inputTaxSelect) {
      let setTaxDivs = function(value) {
        divTaxRange.style.display = value == "over_30000" ? "block" : "none";
      };
      setTaxDivs(inputTaxSelect.value);
      inputTaxSelect.addEventListener("change", (e) => {
        setTaxDivs(e.target.value);
      });
    }
  }
  const submissionButton = document.getElementsByClassName("sau-submission-button")[0];
  if (submissionButton) {
    submissionButton.addEventListener("click", onceClicked);
    addEventListener("pageshow", (e) => {
      alreadyClicked = false;
    });
  }
  const reportDueDate = document.getElementsByClassName("sau-report-due")[0];
  if (reportDueDate) {
    const warningText = document.getElementsByClassName("sau-date-warning")[0];
    if (warningText) {
      const maxDate = new Date(reportDueDate.getAttribute("data-sau-max"));
      warningText.style.display = reportDueDate.value == "" || new Date(reportDueDate.value) <= maxDate ? "none" : "block";
      reportDueDate.addEventListener("change", (e) => {
        warningText.style.display = new Date(e.target.value) <= maxDate ? "none" : "block";
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
    } else {
      const paOrg2Select2 = document.getElementsByClassName("pa-org-2-select")[0];
      for (let index = 0; index < paOrg2Select2.options.length; index++) {
        const element = paOrg2Select2.options[index];
        if (element.parentElement.tagName === "OPTGROUP") {
          element.hidden = element.parentElement.label !== paOrg1.value;
          element.parentElement.hidden = element.hidden;
          element.selected = !element.hidden && element.label === paOrg2.value;
        }
      }
      document.getElementsByClassName("pa-org-2-select-fg")[0].style.display = "block";
      if (paOrg2.value === "") {
        document.getElementsByClassName("pa-org-2-fg")[0].style.display = "block";
      }
    }
    paOrg1Select.addEventListener("change", (e) => {
      const paOrg12 = document.getElementsByClassName("pa-org-1")[0];
      const paOrg22 = document.getElementsByClassName("pa-org-2")[0];
      if (e.target.value === "") {
        paOrg12.value = "";
        paOrg22.value = "";
        document.getElementsByClassName("pa-org-1-fg")[0].style.display = "block";
        document.getElementsByClassName("pa-org-2-fg")[0].style.display = "block";
        document.getElementsByClassName("pa-org-2-select-fg")[0].style.display = "none";
      } else {
        paOrg12.value = e.target.value;
        document.getElementsByClassName("pa-org-1-fg")[0].style.display = "none";
        const paOrg2Select2 = document.getElementsByClassName("pa-org-2-select")[0];
        for (let index = 0; index < paOrg2Select2.options.length; index++) {
          const element = paOrg2Select2.options[index];
          if (element.parentElement.tagName === "OPTGROUP") {
            element.hidden = element.parentElement.label !== e.target.value;
            element.parentElement.hidden = element.hidden;
            element.selected = !element.hidden && element.label === paOrg22.value;
          }
        }
        const paOrg2SelectFg = document.getElementsByClassName("pa-org-2-select-fg")[0].style.display = "block";
        if (paOrg2Select2.selectedOptions[0].value === "") {
          paOrg22.value = "";
          const paOrg2Fg = document.getElementsByClassName("pa-org-2-fg")[0].style.display = "block";
        } else {
          const paOrg2Fg = document.getElementsByClassName("pa-org-2-fg")[0].style.display = "none";
        }
      }
    });
    paOrg2Select.addEventListener("change", (e) => {
      const paOrg22 = document.getElementsByClassName("pa-org-2")[0];
      if (e.target.value === "") {
        paOrg22.value = "";
        document.getElementsByClassName("pa-org-2-fg")[0].style.display = "block";
      } else {
        paOrg22.value = e.target.value;
        document.getElementsByClassName("pa-org-2-fg")[0].style.display = "none";
      }
    });
  }
});
/*! Bundled license information:

govuk-frontend/dist/govuk/components/accordion/accordion.mjs:
  (**
   * Accordion component
   *
   * This allows a collection of sections to be collapsed by default, showing only
   * their headers. Sections can be expanded or collapsed individually by clicking
   * their headers. A "Show all sections" button is also added to the top of the
   * accordion, which switches to "Hide all sections" when all the sections are
   * expanded.
   *
   * The state of each section is saved to the DOM via the `aria-expanded`
   * attribute, which also provides accessibility.
   *
   * @preserve
   *)

govuk-frontend/dist/govuk/components/button/button.mjs:
  (**
   * JavaScript enhancements for the Button component
   *
   * @preserve
   *)

govuk-frontend/dist/govuk/components/character-count/character-count.mjs:
  (**
   * Character count component
   *
   * Tracks the number of characters or words in the `.govuk-js-character-count`
   * `<textarea>` inside the element. Displays a message with the remaining number
   * of characters/words available, or the number of characters/words in excess.
   *
   * You can configure the message to only appear after a certain percentage
   * of the available characters/words has been entered.
   *
   * @preserve
   *)

govuk-frontend/dist/govuk/components/checkboxes/checkboxes.mjs:
  (**
   * Checkboxes component
   *
   * @preserve
   *)

govuk-frontend/dist/govuk/components/error-summary/error-summary.mjs:
  (**
   * Error summary component
   *
   * Takes focus on initialisation for accessible announcement, unless disabled in
   * configuration.
   *
   * @preserve
   *)

govuk-frontend/dist/govuk/components/exit-this-page/exit-this-page.mjs:
  (**
   * Exit this page component
   *
   * @preserve
   *)

govuk-frontend/dist/govuk/components/header/header.mjs:
  (**
   * Header component
   *
   * @preserve
   *)

govuk-frontend/dist/govuk/components/notification-banner/notification-banner.mjs:
  (**
   * Notification Banner component
   *
   * @preserve
   *)

govuk-frontend/dist/govuk/components/radios/radios.mjs:
  (**
   * Radios component
   *
   * @preserve
   *)

govuk-frontend/dist/govuk/components/skip-link/skip-link.mjs:
  (**
   * Skip link component
   *
   * @preserve
   *)

govuk-frontend/dist/govuk/components/tabs/tabs.mjs:
  (**
   * Tabs component
   *
   * @preserve
   *)
*/
//# sourceMappingURL=/assets/application.js.map
