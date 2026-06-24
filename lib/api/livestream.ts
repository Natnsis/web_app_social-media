import { get } from "./client"
import { useAuthStore } from "@/lib/store/auth"

function token() {
  return useAuthStore.getState().accessToken ?? undefined
}

export interface LiveStreamChurch {
  id: string
  name: string
  logoUrl: string | null
  slug: string
}

export interface LiveStream {
  id: string
  churchId: string
  title: string
  description: string | null
  viewerCount: number
  thumbnailUrl: string | null
  isLive: boolean
  startedAt: string
  church: LiveStreamChurch
}

export interface LiveStreamsResponse {
  success: boolean
  data: LiveStream[]
}

export function apiGetLiveStreams() {
  return get<LiveStreamsResponse>("/v1/livestream", token())
}

export function apiGetLiveStream(id: string) {
  return get<{ success: boolean; data: LiveStream }>(`/v1/livestream/${id}`, token())
}
