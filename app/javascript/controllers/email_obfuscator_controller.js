import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["email"]
  static values = {
    encoded: String,
    delay: { type: Number, default: 300 }
  }

  connect() {
    // Delay rendering to make it harder for simple crawlers
    setTimeout(() => {
      this.renderEmail()
    }, this.delayValue)
  }

  renderEmail() {
    if (!this.hasEmailTarget || !this.encodedValue) return

    try {
      // Decode the base64 encoded email
      const decoded = atob(this.encodedValue)

      // Extra step: reverse the string (additional obfuscation)
      const email = decoded.split('').reverse().join('')

      // Create a proper mailto link
      const link = document.createElement('a')
      link.href = `mailto:${email}`
      link.textContent = email

      // For accessibility: add aria-label and role
      link.setAttribute('aria-label', `E-Mail-Adresse: ${email}`)
      link.setAttribute('role', 'link')

      // Add some CSS classes for styling
      link.className = 'email-link'

      // Replace the placeholder content with fade-in effect
      this.emailTarget.style.opacity = '0'
      this.emailTarget.innerHTML = ''
      this.emailTarget.appendChild(link)

      // Fade in the email
      requestAnimationFrame(() => {
        this.emailTarget.style.transition = 'opacity 0.3s ease-in'
        this.emailTarget.style.opacity = '1'
      })
    } catch (error) {
      // Fallback for accessibility - show a readable format
      console.error('Email decoding failed:', error)
      this.emailTarget.textContent = this.emailTarget.textContent || 'E-Mail-Adresse'
    }
  }

  // Optional: Method to copy email to clipboard
  copyEmail(event) {
    event.preventDefault()
    const link = this.emailTarget.querySelector('a')
    if (link && link.textContent) {
      const email = link.textContent
      navigator.clipboard.writeText(email).then(() => {
        // Visual feedback
        const originalText = link.textContent
        link.textContent = 'Kopiert!'
        setTimeout(() => {
          link.textContent = originalText
        }, 2000)
      })
    }
  }
}