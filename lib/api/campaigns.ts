import { get, del, postFormData, patchFormData } from "./client"
import { useAuthStore } from "@/lib/store/auth"
import type { PostsMeta } from "@/types"

function token() {
  return useAuthStore.getState().accessToken ?? undefined
}

export interface CampaignChurch {
  id: string
  name: string
  logoUrl: string | null
  slug: string
}

export interface CampaignCreator {
  id: string
  fullName: string
  avatarUrl: string | null
}

export interface CampaignCount {
  contributions: number
  updates: number
}

export interface Campaign {
  id: string
  churchId: string
  createdByUserId: string
  title: string
  description: string
  goalAmount: number
  currentBalance: number
  coverImageUrl: string | null
  startsAt: string
  endsAt: string
  status: "DRAFT" | "ACTIVE" | "PAUSED" | "COMPLETED" | "CANCELLED"
  isActive: boolean
  completedAt: string | null
  donorCount: number
  contributionCount: number
  createdAt: string
  updatedAt: string
  deletedAt: string | null
  church: CampaignChurch
  createdBy: CampaignCreator
  _count: CampaignCount
}

export interface CampaignsResponse {
  success: boolean
  data: Campaign[]
  meta: PostsMeta
  timestamp: string
}

export interface CampaignResponse {
  success: boolean
  data: Campaign
  timestamp: string
}

export interface CreateCampaignPayload {
  title: string
  description: string
  goalAmount: number
  startAt: string
  endAt: string
  isActive: boolean
  status: "DRAFT" | "ACTIVE" | "PAUSED" | "COMPLETED" | "CANCELLED"
  image?: File | null
}

export function apiGetCampaigns(page = 1, limit = 20) {
  return get<CampaignsResponse>(`/v1/campaigns?page=${page}&limit=${limit}`, token())
}

export function apiGetCampaign(id: string) {
  return get<CampaignResponse>(`/v1/campaigns/${id}`, token())
}

export function apiCreateCampaign(payload: CreateCampaignPayload) {
  const formData = new FormData()
  formData.append("title", payload.title)
  formData.append("description", payload.description)
  formData.append("goalAmount", String(payload.goalAmount))
  formData.append("startAt", payload.startAt)
  formData.append("endAt", payload.endAt)
  formData.append("isActive", String(payload.isActive))
  formData.append("status", payload.status)
  if (payload.image) {
    formData.append("image", payload.image)
  }
  return postFormData<CampaignResponse>("/v1/campaigns", formData, token())
}

export function apiUpdateCampaign(id: string, payload: Partial<CreateCampaignPayload>) {
  const formData = new FormData()
  if (payload.title !== undefined) formData.append("title", payload.title)
  if (payload.description !== undefined) formData.append("description", payload.description)
  if (payload.goalAmount !== undefined) formData.append("goalAmount", String(payload.goalAmount))
  if (payload.startAt !== undefined) formData.append("startAt", payload.startAt)
  if (payload.endAt !== undefined) formData.append("endAt", payload.endAt)
  if (payload.isActive !== undefined) formData.append("isActive", String(payload.isActive))
  if (payload.status !== undefined) formData.append("status", payload.status)
  if (payload.image) formData.append("image", payload.image)
  return patchFormData<CampaignResponse>(`/v1/campaigns/${id}`, formData, token())
}

export function apiDeleteCampaign(id: string) {
  return del<{ success: boolean; timestamp: string }>(`/v1/campaigns/${id}`, token())
}

export interface CampaignContribution {
  id: string
  userId: string
  fullName: string
  initials: string
  avatarUrl: string | null
  amount: number
  createdAt: string
}

export interface CampaignContributionsResponse {
  success: boolean
  data: CampaignContribution[]
  timestamp: string
}

export interface CampaignUpdate {
  id: string
  title: string
  body: string
  createdAt: string
}

export interface CampaignUpdatesResponse {
  success: boolean
  data: CampaignUpdate[]
  timestamp: string
}

export function apiGetCampaignContributions(id: string) {
  return get<CampaignContributionsResponse>(`/v1/campaigns/${id}/contributions`, token())
}

export function apiGetCampaignUpdates(id: string) {
  return get<CampaignUpdatesResponse>(`/v1/campaigns/${id}/updates`, token())
}

export function apiGetCampaignsFollowing(page = 1, limit = 20) {
  return get<CampaignsResponse>(`/v1/campaigns/following?page=${page}&limit=${limit}`, token())
}

export function apiGetCampaignsByChurch(churchId: string, page = 1, limit = 20) {
  return get<CampaignsResponse>(`/v1/campaigns/church/${churchId}?page=${page}&limit=${limit}`, token())
}
