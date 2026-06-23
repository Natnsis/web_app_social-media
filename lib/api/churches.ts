import { get, post, del } from "./client"
import { useAuthStore } from "@/lib/store/auth"
import type { ChurchDetailResponse } from "@/types"

function token() {
  return useAuthStore.getState().accessToken ?? undefined
}

export interface NearbyChurch {
  id: string
  name: string
  logoUrl: string | null
  slug: string
  latitude: number
  longitude: number
  distance: number
  address: string
}

export interface NearbyChurchesResponse {
  success: boolean
  data: NearbyChurch[]
}

const mockChurches: NearbyChurch[] = [
  { id: "beza", name: "Beza Community Church", logoUrl: null, slug: "beza", latitude: 9.0234, longitude: 38.7432, distance: 0.4, address: "Bole Subcity, Addis Ababa" },
  { id: "summit", name: "Summit Fellowship", logoUrl: null, slug: "summit", latitude: 9.0421, longitude: 38.7543, distance: 1.3, address: "Kazanchis, Addis Ababa" },
  { id: "grace", name: "Grace Chapel", logoUrl: null, slug: "grace", latitude: 9.0156, longitude: 38.7610, distance: 2.1, address: "CMC Road, Addis Ababa" },
  { id: "hope", name: "Hope Valley Church", logoUrl: null, slug: "hope", latitude: 9.0543, longitude: 38.7701, distance: 2.8, address: "Bole Medhanealem, Addis Ababa" },
  { id: "zion", name: "Zion Baptist Church", logoUrl: null, slug: "zion", latitude: 9.0089, longitude: 38.7289, distance: 3.5, address: "Megenagna, Addis Ababa" },
  { id: "newlife", name: "New Life Ministry", logoUrl: null, slug: "new-life", latitude: 9.0367, longitude: 38.7802, distance: 4.2, address: "Ayat, Addis Ababa" },
  { id: "calvary", name: "Calvary Temple", logoUrl: null, slug: "calvary", latitude: 9.0478, longitude: 38.7189, distance: 5.1, address: "Saris, Addis Ababa" },
  { id: "kingdom", name: "Kingdom Faith Center", logoUrl: null, slug: "kingdom", latitude: 9.0123, longitude: 38.7923, distance: 6.0, address: "Koye Feche, Addis Ababa" },
]

export function apiGetNearbyChurches(lat: number, lng: number, radiusKm = 50) {
  return get<NearbyChurchesResponse>(
    `/v1/churches/nearby?lat=${lat}&lng=${lng}&radius=${radiusKm}`,
    token()
  ).catch(() => {
    const filtered = mockChurches.filter((c) => c.distance <= radiusKm)
    return { success: true, data: filtered }
  })
}

export function apiFollowChurch(id: string) {
  return post<{ success: boolean }>(`/v1/churches/${id}/follow`, undefined, token())
}

export function apiUnfollowChurch(id: string) {
  return del<{ success: boolean }>(`/v1/churches/${id}/follow`, token())
}

export function apiGetChurch(id: string) {
  return get<ChurchDetailResponse>(`/v1/churches/${id}`, token())
}
