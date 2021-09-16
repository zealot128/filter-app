import 'core-js/stable';
import Automount from 'utils/automount';
import store from "../front-page/store";
import App from "../front-page/components/FrontPage";

document.addEventListener('DOMContentLoaded', () => {
    const tokenDom = document.getElementsByName('csrf-token')[0];
    if (tokenDom) {
        const token = tokenDom.getAttribute('content');
    }
    Automount('front-page-app', App, {store});
});
