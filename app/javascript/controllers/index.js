// Import and register all your controllers from the importmap under controllers/*

import { application } from "./application"

// Eager load all controllers defined in the import map under controllers/**/*_controller
import EmailObfuscatorController from "./email_obfuscator_controller"

application.register("email-obfuscator", EmailObfuscatorController)