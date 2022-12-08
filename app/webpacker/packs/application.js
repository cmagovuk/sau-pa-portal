require.context('govuk-frontend/govuk/assets');

import '../styles/application.scss';
import Rails from 'rails-ujs';
//import Turbolinks from 'turbolinks';
import { initAll } from 'govuk-frontend';
import '../src/uploadDocs';

Rails.start();
//Turbolinks.start();
initAll();
