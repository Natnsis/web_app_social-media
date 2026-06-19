import { post as apiPost } from "./client"

// ── Types ──────────────────────────────────────────────────────────────────────

export interface LoginResponse {
  success: boolean
  data: {
    accessToken: string
    refreshToken: string
    roles: string[]
  }
  timestamp: string
}

export interface AuthResponse {
  success: boolean
  message?: string
  data?: unknown
  timestamp?: string
}

// ── Auth endpoints ─────────────────────────────────────────────────────────────

/** POST /v1/auth/login  — emailOrPhone + password */
export function apiLogin(emailOrPhone: string, password: string) {
  return apiPost<LoginResponse>("/v1/auth/login", { emailOrPhone, password })
}

/** POST /v1/auth/register */
export function apiRegister(payload: {
  fullName: string
  email: string
  phoneNumber: string
  password: string
}) {
  return apiPost<AuthResponse>("/v1/auth/register", payload)
}

/** POST /v1/auth/otp/resend */
export function apiResendOtp(phoneNumber: string) {
  return apiPost<AuthResponse>("/v1/auth/otp/resend", { phoneNumber })
}

/** POST /v1/auth/otp/verify */
export function apiVerifyOtp(phoneNumber: string, otp: string) {
  return apiPost<AuthResponse>("/v1/auth/otp/verify", { phoneNumber, otp })
}

/** POST /v1/auth/login/google */
export function apiGoogleLogin(idToken: string) {
  return apiPost<LoginResponse>("/v1/auth/login/google", { idToken })
}

/** POST /v1/auth/refresh */
export function apiRefreshToken(refreshToken: string) {
  return apiPost<LoginResponse>("/v1/auth/refresh", { refreshToken })
}

/** POST /v1/auth/logout */
export function apiLogout(accessToken: string) {
  return apiPost<AuthResponse>("/v1/auth/logout", {}, accessToken)
}

/** POST /v1/auth/password/change  (change password while authenticated) */
export function apiChangePassword(
  oldPassword: string,
  newPassword: string,
  confirmPassword: string,
  accessToken: string,
) {
  return apiPost<AuthResponse>(
    "/v1/auth/password/change",
    { oldPassword, newPassword, confirmPassword },
    accessToken,
  )
}

/** POST /v1/auth/password/forgot */
export function apiForgotPassword(phoneNumber: string) {
  return apiPost<AuthResponse>("/v1/auth/password/forgot", { phoneNumber })
}

/** POST /v1/auth/password/reset */
export function apiResetPassword(payload: {
  phoneNumber: string
  otp: string
  newPassword: string
  confirmPassword: string
}) {
  return apiPost<AuthResponse>("/v1/auth/password/reset", payload)
}

/** POST /v1/auth/phone/add */
export function apiAddPhone(phoneNumber: string, accessToken: string) {
  return apiPost<AuthResponse>("/v1/auth/phone/add", { phoneNumber }, accessToken)
}
