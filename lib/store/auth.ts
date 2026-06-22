import { create } from "zustand"
import { persist, createJSONStorage } from "zustand/middleware"
import { apiLogout } from "@/lib/api/auth"

export interface AuthUser {
  id: string
  name: string
  email: string
  initials: string
  roles: string[]
  role: string
  org: string
}

interface AuthState {
  accessToken: string | null
  refreshToken: string | null
  user: AuthUser | null
  isAuthenticated: boolean
  setAuthData: (accessToken: string, refreshToken: string) => void
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
        .join("")
    )
    const payload = JSON.parse(jsonPayload)
    const roles = payload.roles || []
    const isChurchOwner = roles.includes("CHURCH_OWNER")
    return {
      id: payload.sub || "1",
      name: payload.name || "Abebe Tesfaye",
      email: payload.email || "user@example.com",
      initials: payload.name ? payload.name.split(" ").map((n: string) => n[0]).join("").toUpperCase() : "AT",
      roles: roles,
      role: isChurchOwner ? "Church Owner" : "Follower",
      org: payload.org || "Beza International",
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
    const base64 = base64Url.replace(/-/g, "+").replace(/_/g, "/")
    const payload = JSON.parse(atob(base64))
    return payload.exp ? Date.now() >= payload.exp * 1000 : true
  } catch {
    return true
  }
}

export const useAuthStore = create<AuthState>()(
  persist(
    (set, get) => ({
      accessToken: null,
      refreshToken: null,
      user: null,
      isAuthenticated: false,
      setAuthData: (accessToken: string, refreshToken: string) => {
        const decoded = decodeJwt(accessToken)
        set({
          accessToken,
          refreshToken,
          user: decoded,
          isAuthenticated: !!decoded,
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
        set({
          accessToken: null,
          refreshToken: null,
          user: null,
          isAuthenticated: false,
        })
      },
    }),
    {
      name: "faith-connect-auth",
      storage: createJSONStorage(() => localStorage),
      skipHydration: true,
    }
  )
)
