import { useAuthStore } from "@/lib/store/auth"
import { refreshAccessToken } from "@/lib/auth/session"

const BASE = process.env.NEXT_PUBLIC_API_URL

export class ApiError extends Error {
  constructor(
    message: string,
    public status: number,
  ) {
    super(message)
    this.name = "ApiError"
  }
}

function resolveToken(explicit?: string): string | undefined {
  return explicit ?? useAuthStore.getState().accessToken ?? undefined
}

async function parseResponse<T>(res: Response): Promise<T> {
  const contentType = res.headers.get("content-type")
  let data: unknown = null
  let responseText = ""

  if (contentType?.includes("application/json")) {
    data = await res.json()
  } else {
    responseText = await res.text()
  }

  if (!res.ok) {
    const payload = data as { message?: string; error?: string } | null
    const errorMsg =
      payload?.message ||
      payload?.error ||
      responseText ||
      `HTTP error! Status: ${res.status}`
    throw new ApiError(errorMsg, res.status)
  }

  return data as T
}

async function request<T>(
  method: string,
  path: string,
  body?: unknown,
  token?: string,
  retried = false,
): Promise<T> {
  const url = `${BASE}${path}`
  const authToken = resolveToken(token)

  const headers: Record<string, string> = {}
  if (!(body instanceof FormData)) {
    headers["Content-Type"] = "application/json"
  }
  if (authToken) {
    headers["Authorization"] = `Bearer ${authToken}`
  }

  const res = await fetch(url, {
    method,
    headers,
    body:
      body instanceof FormData
        ? body
        : body !== undefined
          ? JSON.stringify(body)
          : undefined,
  })

  if (res.status === 401 && !retried && authToken) {
    const newToken = await refreshAccessToken()
    if (newToken) {
      return request<T>(method, path, body, newToken, true)
    }
  }

  return parseResponse<T>(res)
}

export function get<T>(path: string, token?: string): Promise<T> {
  return request<T>("GET", path, undefined, token)
}

export function post<T>(path: string, body?: unknown, token?: string): Promise<T> {
  return request<T>("POST", path, body, token)
}

export function del<T = void>(path: string, token?: string): Promise<T> {
  return request<T>("DELETE", path, undefined, token)
}

export function patch<T>(path: string, body?: unknown, token?: string): Promise<T> {
  return request<T>("PATCH", path, body, token)
}

/** @deprecated FormData is handled automatically by post/patch — kept for call-site compatibility. */
export function postFormData<T>(path: string, formData: FormData, token?: string): Promise<T> {
  return post<T>(path, formData, token)
}

/** @deprecated FormData is handled automatically by post/patch — kept for call-site compatibility. */
export function patchFormData<T>(path: string, formData: FormData, token?: string): Promise<T> {
  return patch<T>(path, formData, token)
}
