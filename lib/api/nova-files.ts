import { postFormData } from "./client"
import { useAuthStore } from "@/lib/store/auth"

function token() {
  return useAuthStore.getState().accessToken ?? undefined
}

export interface NovaFileResponse {
  success: boolean
  data: {
    id: string
    novaUrl: string
    name: string
    mimeType: string
    size: number
  }
  timestamp: string
}

export function apiUploadFile(file: File) {
  const fd = new FormData()
  fd.append("file", file)
  return postFormData<NovaFileResponse>("/v1/nova-files", fd, token())
}
