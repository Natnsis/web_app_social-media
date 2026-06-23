const BASE = process.env.NEXT_PUBLIC_API_URL

async function request<T>(
  method: string,
  path: string,
  body?: unknown,
  token?: string,
): Promise<T> {
  const url = `${BASE}${path}`
  console.log(`[API REQUEST] ${method} ${url}`, { body, hasToken: !!token })

  const headers: Record<string, string> = {
    "Content-Type": "application/json",
  }
  if (token) {
    headers["Authorization"] = `Bearer ${token}`
  }

  try {
    const res = await fetch(url, {
      method,
      headers,
      body: body ? JSON.stringify(body) : undefined,
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
      const errorMsg =
        data?.message || data?.error || responseText || `HTTP error! Status: ${res.status}`
      console.warn(`[API ERROR] ${method} ${path} failed with Status ${res.status}:`, {
        url,
        status: res.status,
        statusText: res.statusText,
        errorPayload: data,
        rawText: responseText,
      })
      throw new Error(errorMsg)
    }

    console.log(`[API SUCCESS] ${method} ${path}:`, data)
    return data as T
  } catch (error: any) {
    console.warn(`[API NETWORK/UNKNOWN ERROR] ${method} ${path}:`, error)
    throw error
  }
}

async function requestFormData<T>(
  method: string,
  path: string,
  formData: FormData,
  token?: string,
): Promise<T> {
  const url = `${BASE}${path}`
  console.log(`[API REQUEST] ${method} ${url} (FormData)`)

  const headers: Record<string, string> = {}
  if (token) {
    headers["Authorization"] = `Bearer ${token}`
  }

  try {
    const res = await fetch(url, { method, headers, body: formData })

    const contentType = res.headers.get("content-type")
    let data: any = null
    let responseText = ""

    if (contentType && contentType.includes("application/json")) {
      data = await res.json()
    } else {
      responseText = await res.text()
    }

    if (!res.ok) {
      const errorMsg =
        data?.message || data?.error || responseText || `HTTP error! Status: ${res.status}`
      console.warn(`[API ERROR] ${method} ${path} failed with Status ${res.status}:`, {
        url,
        status: res.status,
        statusText: res.statusText,
        errorPayload: data,
        rawText: responseText,
      })
      throw new Error(errorMsg)
    }

    console.log(`[API SUCCESS] ${method} ${path}:`, data)
    return data as T
  } catch (error: any) {
    console.warn(`[API NETWORK/UNKNOWN ERROR] ${method} ${path}:`, error)
    throw error
  }
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

export function postFormData<T>(path: string, formData: FormData, token?: string): Promise<T> {
  return requestFormData<T>("POST", path, formData, token)
}

export function patchFormData<T>(path: string, formData: FormData, token?: string): Promise<T> {
  return requestFormData<T>("PATCH", path, formData, token)
}
