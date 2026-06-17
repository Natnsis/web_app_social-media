const BASE = process.env.NEXT_PUBLIC_API_URL

async function post<T>(path: string, body: unknown, token?: string): Promise<T> {
  const url = `${BASE}${path}`
  console.log(`[API REQUEST] POST ${url}`, { body, hasToken: !!token })

  try {
    const res = await fetch(url, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        ...(token ? { Authorization: `Bearer ${token}` } : {}),
      },
      body: JSON.stringify(body),
    })

    const contentType = res.headers.get("content-type")
    let data: any = null
    let responseText = ""

    if (contentType && contentType.includes("application/json")) {
      data = await res.json()
    } else {
      responseText = await res.text()
    }

    if (!res.ok) {
      const errorMsg = data?.message || data?.error || responseText || `HTTP error! Status: ${res.status}`
      console.error(`[API ERROR] POST ${path} failed with Status ${res.status}:`, {
        url,
        status: res.status,
        statusText: res.statusText,
        errorPayload: data,
        rawText: responseText,
      })
      throw new Error(errorMsg)
    }

    console.log(`[API SUCCESS] POST ${path}:`, data)
    return data as T
  } catch (error: any) {
    console.error(`[API NETWORK/UNKNOWN ERROR] POST ${path}:`, error)
    throw error
  }
}

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
  return post<LoginResponse>("/v1/auth/login", { emailOrPhone, password })
}

/** POST /v1/auth/register */
export function apiRegister(payload: {
  fullName: string
  email: string
  phoneNumber: string
  password: string
}) {
  return post<AuthResponse>("/v1/auth/register", payload)
}

/** POST /v1/auth/otp/resend */
export function apiResendOtp(phoneNumber: string) {
  return post<AuthResponse>("/v1/auth/otp/resend", { phoneNumber })
}

/** POST /v1/auth/otp/verify */
export function apiVerifyOtp(phoneNumber: string, otp: string) {
  return post<AuthResponse>("/v1/auth/otp/verify", { phoneNumber, otp })
}

/** POST /v1/auth/login/google */
export function apiGoogleLogin(idToken: string) {
  return post<LoginResponse>("/v1/auth/login/google", { idToken })
}

/** POST /v1/auth/refresh */
export function apiRefreshToken(refreshToken: string) {
  return post<LoginResponse>("/v1/auth/refresh", { refreshToken })
}

/** POST /v1/auth/logout */
export function apiLogout(accessToken: string) {
  return post<AuthResponse>("/v1/auth/logout", {}, accessToken)
}

/** POST /v1/auth/password/change  (change password while authenticated) */
export function apiChangePassword(
  oldPassword: string,
  newPassword: string,
  confirmPassword: string,
  accessToken: string,
) {
  return post<AuthResponse>(
    "/v1/auth/password/change",
    { oldPassword, newPassword, confirmPassword },
    accessToken,
  )
}

/** POST /v1/auth/password/forgot */
export function apiForgotPassword(phoneNumber: string) {
  return post<AuthResponse>("/v1/auth/password/forgot", { phoneNumber })
}

/** POST /v1/auth/password/reset */
export function apiResetPassword(payload: {
  phoneNumber: string
  otp: string
  newPassword: string
  confirmPassword: string
}) {
  return post<AuthResponse>("/v1/auth/password/reset", payload)
}

/** POST /v1/auth/phone/add */
export function apiAddPhone(phoneNumber: string, accessToken: string) {
  return post<AuthResponse>("/v1/auth/phone/add", { phoneNumber }, accessToken)
}
