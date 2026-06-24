import { useAuthStore } from "@/lib/store/auth"

const BASE = process.env.NEXT_PUBLIC_API_URL

async function get<T>(path: string, token: string): Promise<T> {
  const url = `${BASE}${path}`

  try {
    const res = await fetch(url, {
      method: "GET",
      headers: {
        Authorization: `Bearer ${token}`,
      },
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
      throw new Error(errorMsg)
    }

    return data as T
  } catch (error: any) {
    console.error(`[API ERROR] GET ${path}:`, error)
    throw error
  }
}

async function patchFormData<T>(path: string, formData: FormData, token: string): Promise<T> {
  const url = `${BASE}${path}`

  try {
    const res = await fetch(url, {
      method: "PATCH",
      headers: {
        Authorization: `Bearer ${token}`,
      },
      body: formData,
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
      throw new Error(errorMsg)
    }

    return data as T
  } catch (error: any) {
    console.error(`[API ERROR] PATCH ${path}:`, error)
    throw error
  }
}

export interface UserProfileRole {
  role: {
    id: string
    name: string
  }
}

export interface UserChurch {
  id: string
  name: string
  logoUrl: string
}

export interface UserProfile {
  id: string
  email: string
  phoneNumber: string | null
  fullName: string
  bio: string | null
  avatarUrl: string | null
  authProvider: string
  registrationStatus: string
  isBanned: boolean
  isEmailVerified: boolean
  isPhoneVerified: boolean
  verifiedAt: string | null
  lastLoginAt: string | null
  latitude: number | null
  longitude: number | null
  locationSharingEnabled: boolean
  lastLocationAt: string | null
  createdAt: string
  updatedAt: string
  deletedAt: string | null
  roles: UserProfileRole[]
  userPermissions: string[]
  isVerified: boolean
  church?: UserChurch | null
  isOnline: boolean
  lastSeenAt: string | null
  lastSeenText: string | null
}

export interface UserProfileResponse {
  success: boolean
  data: UserProfile
  timestamp: string
}

function token() {
  return useAuthStore.getState().accessToken ?? undefined
}

export function apiGetProfile(passedToken?: string) {
  const authToken = passedToken || token()
  return get<UserProfileResponse>("/v1/users/me", authToken || "")
}

export function apiUpdateProfile(formData: FormData, passedToken?: string) {
  const authToken = passedToken || token()
  return patchFormData<UserProfileResponse>("/v1/users/me", formData, authToken || "")
}

export interface SearchUsersResponse {
  success: boolean
  data: Array<{
    id: string
    fullName: string
    avatarUrl: string | null
    bio: string | null
  }>
}

export function apiSearchUsers(query: string, page = 1, limit = 20) {
  return get<SearchUsersResponse>(`/v1/users/search?q=${encodeURIComponent(query)}&page=${page}&limit=${limit}`, "")
}

export function apiUpdateLocation(latitude: number, longitude: number) {
  const authToken = token()
  return fetch(`${BASE}/v1/users/me/location`, {
    method: "PATCH",
    headers: {
      "Content-Type": "application/json",
      ...(authToken ? { Authorization: `Bearer ${authToken}` } : {}),
    },
    body: JSON.stringify({ latitude, longitude }),
  }).then((r) => r.json()) as Promise<{ success: boolean }>
}
