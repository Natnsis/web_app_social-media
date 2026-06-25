import { create } from "zustand"
import { persist, createJSONStorage } from "zustand/middleware"
import { immer } from "zustand/middleware/immer"
import { apiLogout } from "@/lib/api/auth"
import {
  canManageChurchContent,
  normalizeRoles,
  primaryRoleLabel,
} from "@/lib/auth/roles"
import { clearSession, syncSession } from "@/lib/auth/session"

export interface AuthUser {
  id: string
  name: string
  email: string
  initials: string
  roles: string[]
  role: string
  org: string
  isChurchOwner: boolean
  canManageChurch: boolean
}

interface AuthState {
  accessToken: string | null
  refreshToken: string | null
  user: AuthUser | null
  isAuthenticated: boolean
  /** Set tokens + user after login; persists to httpOnly cookies. */
  setAuthData: (accessToken: string, refreshToken: string) => Promise<void>
  /** Internal: update tokens after refresh (cookies already set by route handler). */
  setTokens: (accessToken: string, refreshToken: string) => void
  clearAuth: () => void
  logout: () => Promise<void>
}

export function decodeJwt(token: string): AuthUser | null {
  try {
    const base64Url = token.split(".")[1]
    if (!base64Url) return null
    const base64 = base64Url.replace(/-/g, "+").replace(/_/g, "/")
    const jsonPayload = decodeURIComponent(
      atob(base64)
        .split("")
        .map((c) => "%" + ("00" + c.charCodeAt(0).toString(16)).slice(-2))
        .join(""),
    )
    const payload = JSON.parse(jsonPayload)
    const roles = normalizeRoles(payload.roles)
    const canManage = canManageChurchContent(roles)
    const name = payload.name || "User"
    return {
      id: payload.sub || "",
      name,
      email: payload.email || "",
      initials: name
        ? name
            .split(" ")
            .map((n: string) => n[0])
            .join("")
            .toUpperCase()
            .slice(0, 2)
        : "U",
      roles,
      role: primaryRoleLabel(roles),
      org: payload.org || payload.churchName || "",
      isChurchOwner: canManage,
      canManageChurch: canManage,
    }
  } catch (error) {
    console.error("Failed to decode JWT token:", error)
    return null
  }
}

export function isTokenExpired(token: string): boolean {
  try {
    const base64Url = token.split(".")[1]
    if (!base64Url) return true
    const payload = JSON.parse(atob(base64Url.replace(/-/g, "+").replace(/_/g, "/")))
    return payload.exp ? Date.now() >= payload.exp * 1000 : true
  } catch {
    return true
  }
}

function applyTokens(
  set: (fn: (state: AuthState) => void) => void,
  accessToken: string,
  refreshToken: string,
) {
  const decoded = decodeJwt(accessToken)
  set((state) => {
    state.accessToken = accessToken
    state.refreshToken = refreshToken
    state.user = decoded
    state.isAuthenticated = !!decoded
  })
}

export const useAuthStore = create<AuthState>()(
  persist(
    immer((set, get) => ({
      accessToken: null,
      refreshToken: null,
      user: null,
      isAuthenticated: false,

      setAuthData: async (accessToken, refreshToken) => {
        applyTokens(set, accessToken, refreshToken)
        await syncSession(accessToken, refreshToken)
      },

      setTokens: (accessToken, refreshToken) => {
        applyTokens(set, accessToken, refreshToken)
      },

      clearAuth: () => {
        set((state) => {
          state.accessToken = null
          state.refreshToken = null
          state.user = null
          state.isAuthenticated = false
        })
      },

      logout: async () => {
        const { accessToken } = get()
        if (accessToken) {
          try {
            await apiLogout(accessToken)
          } catch (e) {
            console.error("API logout request failed", e)
          }
        }
        await clearSession()
        set((state) => {
          state.accessToken = null
          state.refreshToken = null
          state.user = null
          state.isAuthenticated = false
        })
      },
    })),
    {
      name: "faith-connect-user",
      storage: createJSONStorage(() => localStorage),
      partialize: (state) => ({ user: state.user }),
      skipHydration: true,
    },
  ),
)
