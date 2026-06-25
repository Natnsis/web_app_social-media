import { NextResponse } from "next/server"
import { AuthApiEndpoint } from "@/lib/api/endpoints"
import { loginResponseSchema } from "@/lib/validation/auth-response"
import { clearAuthCookies, readAuthCookies, setAuthCookies } from "@/lib/auth/cookies"

const API_BASE = process.env.NEXT_PUBLIC_API_URL

export async function POST() {
  const { refreshToken } = await readAuthCookies()
  if (!refreshToken) {
    return NextResponse.json({ error: "No refresh token" }, { status: 401 })
  }

  try {
    const res = await fetch(`${API_BASE}${AuthApiEndpoint.refresh}`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ refreshToken }),
    })

    if (!res.ok) {
      await clearAuthCookies()
      return NextResponse.json({ error: "Refresh failed" }, { status: 401 })
    }

    const json = await res.json()
    const parsed = loginResponseSchema.safeParse(json)
    if (!parsed.success) {
      return NextResponse.json({ error: "Invalid refresh response" }, { status: 502 })
    }

    const { accessToken, refreshToken: newRefresh } = parsed.data.data
    await setAuthCookies(accessToken, newRefresh)

    return NextResponse.json({ accessToken, refreshToken: newRefresh })
  } catch {
    return NextResponse.json({ error: "Refresh request failed" }, { status: 502 })
  }
}
