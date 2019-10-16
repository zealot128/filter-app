import Vue from 'vue';

import _mapValues from 'lodash/mapValues'
const rbrace = /^(?:\{[\w\W]*\}|\[[\w\W]*\])$/

// aus jquery data
const parseData = (data) => {
	if ( data === "true" ) {
		return true;
	}
	if ( data === "false" ) {
		return false;
	}
	if ( data === "null" ) {
		return null;
	}
	// Only convert to a number if it doesn't change the string
	if ( data === +data + "" ) {
		return +data;
	}
	if ( rbrace.test( data ) ) {
		return JSON.parse( data );
	}
	return data;
}
const Automount = (componentName, component, extra = {}) => {
  Array.from(document.querySelectorAll(componentName)).forEach((el) => {
    const data = _mapValues({...el.dataset }, (d) => {
      return parseData(d)
    })
    const app = new Vue({
      ...extra,
      el,
      render: (h) => h(component, { props: data })
    })
  })
}

export default Automount;
