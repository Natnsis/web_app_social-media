import { get, post, del } from "./client"
import { useAuthStore } from "@/lib/store/auth"
import type { ApiResponse } from "@/types"

function token() {
  return useAuthStore.getState().accessToken ?? undefined
}

export interface EventMeta {
  page: number
  limit: number
  total: number
  totalPages: number
  hasNextPage: boolean
  hasPreviousPage: boolean
}

export interface ChurchInfo {
  id: string
  name: string
  logoUrl: string | null
  slug: string
}

export interface EventItem {
  id: string
  churchId: string
  title: string
  description: string
  startDate: string
  endDate: string
  location: string | null
  imageUrl: string | null
  maxAttendees: number | null
  status: "upcoming" | "ongoing" | "completed" | "cancelled"
  isPublic: boolean
  createdAt: string
  updatedAt: string
  timeAgo: string
  church: ChurchInfo
  attendeeCount: number
}

export interface CreateEventPayload {
  title: string
  description: string
  startDate: string
  endDate: string
  location?: string
  maxAttendees?: number
  isPublic?: boolean
}

export interface UpdateEventPayload {
  title?: string
  description?: string
  startDate?: string
  endDate?: string
  location?: string
  maxAttendees?: number
  isPublic?: boolean
}

export interface EventsResponse {
  success: boolean
  data: EventItem[]
  meta: EventMeta
}

export function apiGetEvents(page = 1, limit = 20, churchId?: string) {
  const query = churchId ? `?page=${page}&limit=${limit}&churchId=${churchId}` : `?page=${page}&limit=${limit}`
  return get<EventsResponse>(`/v1/events${query}`, token())
}

export function apiGetMyEvents(page = 1, limit = 20) {
  return get<EventsResponse>(`/v1/events/mine?page=${page}&limit=${limit}`, token())
}

export function apiGetEventsByChurch(churchId: string, page = 1, limit = 20) {
  return get<EventsResponse>(`/v1/events/church/${churchId}?page=${page}&limit=${limit}`, token())
}

export function apiGetEvent(id: string) {
  return get<{ success: boolean; data: EventItem }>(`/v1/events/${id}`, token())
}

export function apiCreateEvent(payload: CreateEventPayload) {
  return post<{ success: boolean; data: { id: string } }>("/v1/events", payload, token())
}

export function apiUpdateEvent(id: string, payload: UpdateEventPayload) {
  return post<ApiResponse>(`/v1/events/${id}`, payload, token())
}

export function apiDeleteEvent(id: string) {
  return del<ApiResponse>(`/v1/events/${id}`, token())
}

export function apiAttendEvent(id: string) {
  return post<ApiResponse>(`/v1/events/${id}/attend`, {}, token())
}

export function apiUnattendEvent(id: string) {
  return del<ApiResponse>(`/v1/events/${id}/attend`, token())
}

export function apiGetEventAttendees(id: string, skip = 0, take = 50) {
  return get<{
    success: boolean
    data: Array<{
      id: string
      fullName: string
      avatarUrl: string | null
      attendedAt: string
    }>
  }>(`/v1/events/${id}/attendees?skip=${skip}&take=${take}`, token())
}
