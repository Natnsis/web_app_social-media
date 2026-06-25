import { post as apiPost } from "./client"
import { AuthApiEndpoint } from "./endpoints"
import {
  type AuthResponse,
  type LoginResponse,
  authResponseSchema,
  loginResponseSchema,
} from "@/lib/validation/auth-response"

export type { LoginResponse, AuthResponse }

/** POST /v1/auth/login */
export function apiLogin(emailOrPhone: string, password: string) {
  return apiPost<LoginResponse>(AuthApiEndpoint.login, { emailOrPhone, password }).then(
    (res) => loginResponseSchema.parse(res),
  )
}

/** POST /v1/auth/register */
export function apiRegister(payload: {
  fullName: string
  email: string
  phoneNumber: string
  password: string
}) {
  return apiPost<AuthResponse>(AuthApiEndpoint.register, payload).then((res) =>
    authResponseSchema.parse(res),
  )
}

/** POST /v1/auth/otp/resend */
export function apiResendOtp(phoneNumber: string) {
  return apiPost<AuthResponse>(AuthApiEndpoint.otpResend, { phoneNumber }).then((res) =>
    authResponseSchema.parse(res),
  )
}

/** POST /v1/auth/otp/verify */
export function apiVerifyOtp(phoneNumber: string, otp: string) {
  return apiPost<AuthResponse>(AuthApiEndpoint.otpVerify, { phoneNumber, otp }).then((res) =>
    authResponseSchema.parse(res),
  )
}

/** POST /v1/auth/login/google */
export function apiGoogleLogin(idToken: string) {
  return apiPost<LoginResponse>(AuthApiEndpoint.loginGoogle, { idToken }).then((res) =>
    loginResponseSchema.parse(res),
  )
}

/** POST /v1/auth/refresh — prefer /api/auth/refresh for cookie-backed sessions. */
export function apiRefreshToken(refreshToken: string) {
  return apiPost<LoginResponse>(AuthApiEndpoint.refresh, { refreshToken }).then((res) =>
    loginResponseSchema.parse(res),
  )
}

/** POST /v1/auth/logout */
export function apiLogout(accessToken: string) {
  return apiPost<AuthResponse>(AuthApiEndpoint.logout, {}, accessToken).then((res) =>
    authResponseSchema.parse(res),
  )
}

/** POST /v1/auth/password/change */
export function apiChangePassword(
  oldPassword: string,
  newPassword: string,
  confirmPassword: string,
  accessToken: string,
) {
  return apiPost<AuthResponse>(
    AuthApiEndpoint.passwordChange,
    { oldPassword, newPassword, confirmPassword },
    accessToken,
  ).then((res) => authResponseSchema.parse(res))
}

/** POST /v1/auth/password/forgot */
export function apiForgotPassword(phoneNumber: string) {
  return apiPost<AuthResponse>(AuthApiEndpoint.passwordForgot, { phoneNumber }).then((res) =>
    authResponseSchema.parse(res),
  )
}

/** POST /v1/auth/password/reset */
export function apiResetPassword(payload: {
  phoneNumber: string
  otp: string
  newPassword: string
  confirmPassword: string
}) {
  return apiPost<AuthResponse>(AuthApiEndpoint.passwordReset, payload).then((res) =>
    authResponseSchema.parse(res),
  )
}

/** POST /v1/auth/phone/add */
export function apiAddPhone(phoneNumber: string, accessToken: string) {
  return apiPost<AuthResponse>(AuthApiEndpoint.phoneAdd, { phoneNumber }, accessToken).then(
    (res) => authResponseSchema.parse(res),
  )
}
