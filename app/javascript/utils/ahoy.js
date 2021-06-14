import ahoy from "ahoy.js";

window.ahoy = ahoy

ahoy.configure({
  cookies: false,
  visitsUrl: "/stellenanzeigen/visits",
  eventsUrl: "/stellenanzeigen/events",
  useBeacon: false,
})

export default ahoy
