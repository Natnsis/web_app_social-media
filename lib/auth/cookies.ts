import { cookies } from "next/headers"

export const ACCESS_COOKIE = "fc_access_token"
export const REFRESH_COOKIE = "fc_refresh_token"

const BASE_COOKIE = {
  httpOnly: true,
  sameSite: "lax" as const,
  path: "/",
  secure: process.env.NODE_ENV === "production",
}

export async function setAuthCookies(accessToken: string, refreshToken: string) {
  const store = await cookies()
  store.set(ACCESS_COOKIE, accessToken, { ...BASE_COOKIE, maxAge: 60 * 60 })
  store.set(REFRESH_COOKIE, refreshToken, { ...BASE_COOKIE, maxAge: 60 * 60 * 24 * 30 })
}

export async function clearAuthCookies() {
  const store = await cookies()
  store.delete(ACCESS_COOKIE)
  store.delete(REFRESH_COOKIE)
}

export async function readAuthCookies(): Promise<{
  accessToken: string | null
  refreshToken: string | null
}> {
  const store = await cookies()
  return {
    accessToken: store.get(ACCESS_COOKIE)?.value ?? null,
    refreshToken: store.get(REFRESH_COOKIE)?.value ?? null,
  }
}
