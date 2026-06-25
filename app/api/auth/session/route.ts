import { NextResponse } from "next/server"
import { z } from "zod"
import {
  clearAuthCookies,
  readAuthCookies,
  setAuthCookies,
} from "@/lib/auth/cookies"

const sessionBodySchema = z.object({
  accessToken: z.string().min(1),
  refreshToken: z.string().min(1),
})

export async function GET() {
  const { accessToken, refreshToken } = await readAuthCookies()
  if (!accessToken || !refreshToken) {
    return NextResponse.json({ error: "No session" }, { status: 401 })
  }
  return NextResponse.json({ accessToken, refreshToken })
}

export async function POST(request: Request) {
  const body = await request.json()
  const parsed = sessionBodySchema.safeParse(body)
  if (!parsed.success) {
    return NextResponse.json({ error: "Invalid session payload" }, { status: 400 })
  }
  await setAuthCookies(parsed.data.accessToken, parsed.data.refreshToken)
  return NextResponse.json({ success: true })
}

export async function DELETE() {
  await clearAuthCookies()
  return NextResponse.json({ success: true })
}
