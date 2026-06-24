import { get, post, del, postFormData, patchFormData } from "./client"
import { useAuthStore } from "@/lib/store/auth"
import type {
  GroupCommentsResponse,
  CreateGroupPayload,
  CreateGroupResponse,
  GroupsResponse,
  GroupMembersResponse,
  ApiResponse,
  MinimalGroup,
} from "@/types"

function token() {
  return useAuthStore.getState().accessToken ?? undefined
}

export function apiGetGroups() {
  return get<GroupsResponse>("/v1/groups", token())
}

export function apiGetGroupComments(groupId: string, skip = 0, take = 30) {
  return get<GroupCommentsResponse>(`/v1/groups/${groupId}/groupmessages?skip=${skip}&take=${take}`, token())
}

export function apiCreateGroup(payload: CreateGroupPayload) {
  return post<CreateGroupResponse>("/v1/groups", payload, token())
}

export function apiCreateGroupFormData(formData: FormData) {
  return postFormData<CreateGroupResponse>("/v1/groups", formData, token())
}

export function apiUpdateGroup(id: string, formData: FormData) {
  return patchFormData<ApiResponse<MinimalGroup>>(`/v1/groups/${id}`, formData, token())
}

export function apiDeleteGroup(id: string) {
  return del<ApiResponse<{ id: string }>>(`/v1/groups/${id}`, token())
}

export function apiGetGroupMembers(id: string) {
  return get<GroupMembersResponse>(`/v1/groups/${id}/members`, token())
}

export function apiJoinGroup(id: string) {
  return post<ApiResponse<{ id: string }>>(`/v1/groups/${id}/join`, undefined, token())
}

export function apiJoinGroupRequest(id: string) {
  return post<ApiResponse<{ id: string }>>(`/v1/groups/${id}/join-requests`, undefined, token())
}

export function apiApproveJoinRequest(groupId: string, userId: string) {
  return post<ApiResponse>(`/v1/groups/${groupId}/join-requests/${userId}/approve`, undefined, token())
}

export function apiRejectJoinRequest(groupId: string, userId: string) {
  return post<ApiResponse>(`/v1/groups/${groupId}/join-requests/${userId}/reject`, undefined, token())
}

export function apiRemoveGroupMember(groupId: string, userId: string) {
  return del<ApiResponse>(`/v1/groups/${groupId}/members/${userId}`, token())
}

export function apiBanGroupMember(groupId: string, userId: string) {
  return post<ApiResponse>(`/v1/groups/${groupId}/bans/${userId}`, undefined, token())
}

export function apiLeaveGroup(groupId: string) {
  return post<ApiResponse>(`/v1/groups/${groupId}/leave`, undefined, token())
}

export function apiInviteGroupMember(groupId: string, userId: string) {
  return post<ApiResponse>(`/v1/groups/${groupId}/members/invite/${userId}`, undefined, token())
}
