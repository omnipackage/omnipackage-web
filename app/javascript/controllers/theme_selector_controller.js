import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "currentTheme", "preferedTheme", "themeButton" ]

  connect() {
    let theme = this.getCookie("theme")
    if (theme && theme != "auto") {
      this.set_theme(theme)
      this.set_active(theme)
    } else {
      this.set_theme(this.prefered_theme())
      this.set_active("auto")
    }

    this.preferedThemeTargets.forEach((element, index) => {
      element.hidden = element.dataset.theme != this.prefered_theme()
    })
  }

  switch(event) {
    let new_theme = event.target.dataset.theme

    this.set_theme(new_theme == "auto" ? this.prefered_theme() : new_theme)
    this.save_theme(new_theme)
    this.set_active(new_theme)
  }

  prefered_theme() {
    // document.querySelector("html").getAttribute("data-bs-theme")
    return window.matchMedia("(prefers-color-scheme: dark)").matches ? "dark" : "light"
  }

  set_theme(theme) {
    document.querySelector("html").setAttribute("data-bs-theme", theme)

    this.currentThemeTargets.forEach((element, index) => {
      element.hidden = element.dataset.theme != theme
    })
  }

  set_active(theme) {
    this.themeButtonTargets.forEach((element, index) => {
      if (element.dataset.theme == theme) {
        element.classList.add("active")
      } else {
        element.classList.remove("active")
      }
    })
  }

  save_theme(theme) {
    this.setCookie("theme", theme, 12345)
  }

  setCookie(cname, cvalue, exdays) {
    const d = new Date();
    d.setTime(d.getTime() + (exdays * 24 * 60 * 60 * 1000));
    let expires = "expires="+d.toUTCString();
    document.cookie = cname + "=" + cvalue + ";" + expires + ";SameSite=Strict;path=/";
  }

  getCookie(cname) {
    let name = cname + "=";
    let ca = document.cookie.split(';');
    for(let i = 0; i < ca.length; i++) {
      let c = ca[i];
      while (c.charAt(0) == ' ') {
        c = c.substring(1);
      }
      if (c.indexOf(name) == 0) {
        return c.substring(name.length, c.length);
      }
    }
    return "";
  }
}
