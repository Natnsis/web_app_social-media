"use client"

import { useAuthStore } from "@/lib/store/auth"

export async function syncSession(accessToken: string, refreshToken: string) {
  await fetch("/api/auth/session", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    credentials: "include",
    body: JSON.stringify({ accessToken, refreshToken }),
  })
}

export async function clearSession() {
  await fetch("/api/auth/session", { method: "DELETE", credentials: "include" })
}

export async function hydrateSession(): Promise<boolean> {
  try {
    const res = await fetch("/api/auth/session", { credentials: "include" })
    if (!res.ok) return false
    const data = await res.json()
    if (data.accessToken && data.refreshToken) {
      useAuthStore.getState().setTokens(data.accessToken, data.refreshToken)
      return true
    }
    return false
  } catch {
    return false
  }
}

let refreshPromise: Promise<string | null> | null = null

/** Refresh access token via httpOnly refresh cookie. Updates Zustand in-memory state. */
export async function refreshAccessToken(): Promise<string | null> {
  if (refreshPromise) return refreshPromise

  refreshPromise = (async () => {
    try {
      const res = await fetch("/api/auth/refresh", {
        method: "POST",
        credentials: "include",
      })
      if (!res.ok) {
        useAuthStore.getState().clearAuth()
        return null
      }
      const data = await res.json()
      useAuthStore.getState().setTokens(data.accessToken, data.refreshToken)
      return data.accessToken as string
    } catch {
      useAuthStore.getState().clearAuth()
      return null
    } finally {
      refreshPromise = null
    }
  })()

  return refreshPromise
}
