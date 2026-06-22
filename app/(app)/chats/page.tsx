"use client"

import { useState } from "react"
import Link from "next/link"
import { useAuthStore } from "@/lib/store/auth"
import { useConversations, useUnreadCount } from "@/hooks/use-conversations"
import { useGroups } from "@/hooks/use-groups"
import { ChatListItem } from "@/components/chat/chat-list-item"
import { ChatThread } from "@/components/chat/chat-thread"
import { Avatar, AvatarFallback } from "@/components/ui/avatar"
import { Button } from "@/components/ui/button"
import { CirclePlus, Search, Users } from "nasicon-react/outline"

type TabType = "direct" | "groups"

export default function ChatsPage() {
  const { user } = useAuthStore()
  const [tab, setTab] = useState<TabType>("direct")
  const [selectedChatId, setSelectedChatId] = useState<string | null>(null)
  const [selectedGroupId, setSelectedGroupId] = useState<string | null>(null)

  const { data: convData, isLoading: convsLoading, isError: convsError } = useConversations()
  const { data: groupsData, isLoading: groupsLoading, isError: groupsError } = useGroups()
  const { data: unreadData } = useUnreadCount()
  const unreadCount = unreadData?.data?.count ?? 0

  const conversations = convData?.data ?? []
  const groups = groupsData?.data ?? []

  const enrichedConversations = conversations.map((conv) => {
    const otherA = conv?.participantA
    const otherB = conv?.participantB
    const other = otherA?.id === user?.id ? otherB : otherA
    const isOnline = !!other?.isOnline
    const msgs = conv?.messages
    const lastMsg = msgs && msgs.length > 0 ? msgs[msgs.length - 1] : null
    return {
      id: conv?.id ?? "",
      name: other?.fullName || "Unknown",
      initials: other?.initials || other?.fullName?.charAt(0).toUpperCase() || "U",
      time: lastMsg?.createdAt
        ? new Date(lastMsg.createdAt).toLocaleTimeString([], { hour: "2-digit", minute: "2-digit" })
        : "",
      lastMsg: lastMsg?.body ?? "Start a conversation",
      unread: 0,
      online: isOnline,
      otherParticipant: other
        ? {
            fullName: other.fullName,
            initials: other.initials || other.fullName.charAt(0).toUpperCase(),
            isOnline,
            lastSeenText: other.lastSeenText ?? null,
          }
        : null,
    }
  })
  const selectedConv = selectedChatId
    ? enrichedConversations.find((c) => c.id === selectedChatId) ?? null
    : null

  const selectedGroup = groups.length > 0
    ? (groups.find((g) => g.id === selectedGroupId) ?? null)
    : null

  return (
    <div className="relative flex h-full min-h-0 flex-col overflow-hidden lg:flex-row lg:overflow-hidden">
      <header className="flex shrink-0 items-center justify-between px-4 py-3 lg:hidden">
        <h1 className="text-xl font-bold">Chat</h1>
        <div className="flex items-center gap-2">
          <Avatar size="sm">
            <AvatarFallback className="bg-primary text-primary-foreground text-xs">{user?.initials ?? "AT"}</AvatarFallback>
          </Avatar>
          <Button variant="ghost" size="icon-sm"><Search size={20} /></Button>
        </div>
      </header>

      <div className="mx-4 mb-3 flex shrink-0 rounded-full bg-muted p-1 lg:hidden">
        {(["direct", "groups"] as const).map((t) => (
          <button
            key={t}
            onClick={() => {
              setTab(t)
              setSelectedChatId(null)
              setSelectedGroupId(null)
            }}
            className={`flex-1 rounded-full py-1.5 text-sm font-semibold capitalize transition-colors ${tab === t ? "bg-primary text-primary-foreground shadow" : "text-muted-foreground"
              }`}
          >
            {t === "direct" ? "Direct" : "Groups"}
          </button>
        ))}
      </div>

      {/* Mobile conversation list */}
      <div className="flex-1 overflow-y-auto pb-20 lg:hidden">
        {tab === "direct" && convsLoading && (
          <div className="flex justify-center py-8"><p className="text-sm text-muted-foreground">Loading conversations...</p></div>
        )}
        {tab === "direct" && convsError && (
          <div className="flex justify-center py-8"><p className="text-sm text-destructive">Failed to load conversations</p></div>
        )}
        {tab === "direct" && !convsLoading && !convsError && enrichedConversations.length === 0 && (
          <div className="flex flex-col items-center justify-center gap-3 py-12 px-4">
            <Users size={40} className="text-muted-foreground/40" />
            <p className="text-sm text-muted-foreground">No conversations yet</p>
          </div>
        )}
        {tab === "direct" &&
          enrichedConversations.map((chat) => (
            <ChatListItem key={chat.id} {...chat} href={`/chats/${chat.id}`} />
          ))}
        {tab === "groups" && groupsLoading && (
          <div className="flex justify-center py-8"><p className="text-sm text-muted-foreground">Loading groups...</p></div>
        )}
        {tab === "groups" && groupsError && (
          <div className="flex justify-center py-8"><p className="text-sm text-destructive">Failed to load groups</p></div>
        )}
        {tab === "groups" && !groupsLoading && !groupsError && groups.length === 0 && (
          <div className="flex flex-col items-center justify-center gap-3 py-12 px-4">
            <Users size={40} className="text-muted-foreground/40" />
            <p className="text-sm text-muted-foreground">
              {user?.role === "Church Owner" ? "Create your first group" : "No groups yet"}
            </p>
          </div>
        )}
        {tab === "groups" &&
          groups.map((group) => (
            <ChatListItem
              key={group?.id}
              id={group?.id ?? ""}
              name={group?.name ?? "Group"}
              initials={group?.name?.slice(0, 2).toUpperCase() ?? "G"}
              time={
                group?.updatedAt
                  ? new Date(group.updatedAt).toLocaleTimeString([], {
                    hour: "2-digit",
                    minute: "2-digit",
                  })
                  : ""
              }
              lastMsg={`${group?._count?.comments ?? 0} messages · ${group?.church?.name ?? ""}`}
              unread={0}
              online={false}
              href={`/chats/${group?.id}?type=group`}
            />
          ))}
      </div>

      {/* Desktop split-pane — also visible on smaller screens via flex-col */}
      <div className="hidden h-full min-h-0 flex-1 flex-col overflow-hidden rounded-2xl border border-border bg-card lg:flex lg:flex-row">
        <aside className="flex w-full shrink-0 flex-col border-r border-border bg-card lg:w-72 xl:w-80">
          <div className="border-b border-border px-4 py-4">
            <div className="flex items-center justify-between gap-3">
              <div>
                <h1 className="text-xl font-black">Messages</h1>
                <p className="text-xs text-muted-foreground">Direct and ministry group chats</p>
              </div>
              <div className="flex items-center gap-2">
                {unreadCount > 0 && (
                  <span className="flex size-6 items-center justify-center rounded-full bg-primary text-[11px] font-bold text-primary-foreground">
                    {unreadCount}
                  </span>
                )}
                {user?.role === "Church Owner" && (
                  <Link
                    href="/chats/new-group"
                    className="flex size-9 items-center justify-center rounded-xl bg-primary text-primary-foreground"
                  >
                    <CirclePlus size={20} />
                  </Link>
                )}
              </div>
            </div>

            <div className="mt-4 flex rounded-xl bg-muted p-1">
              {(["direct", "groups"] as const).map((t) => (
                <button
                  key={t}
                  onClick={() => {
                    setTab(t)
                    setSelectedChatId(null)
                    setSelectedGroupId(null)
                  }}
                  className={`flex-1 rounded-lg py-2 text-sm font-semibold capitalize transition-colors ${tab === t ? "bg-background text-foreground" : "text-muted-foreground hover:text-foreground"
                    }`}
                >
                  {t === "direct" ? "Direct" : "Groups"}
                </button>
              ))}
            </div>

            <div className="relative mt-3">
              <Search size={15} className="absolute left-3 top-1/2 -translate-y-1/2 text-muted-foreground" />
              <input
                placeholder="Search conversations"
                className="h-10 w-full rounded-xl border border-border bg-background pl-9 pr-3 text-sm outline-none focus:border-primary"
              />
            </div>
          </div>

          <div className="flex-1 overflow-y-auto">
            {tab === "direct" && convsLoading && (
              <div className="flex justify-center py-8"><p className="text-sm text-muted-foreground">Loading conversations...</p></div>
            )}
            {tab === "direct" && convsError && (
              <div className="flex justify-center py-8"><p className="text-sm text-destructive">Failed to load conversations</p></div>
            )}
            {tab === "direct" && !convsLoading && !convsError && enrichedConversations.length === 0 && (
              <div className="flex justify-center py-8 px-4">
                <p className="text-sm text-muted-foreground">No conversations yet</p>
              </div>
            )}
            {tab === "direct" &&
              enrichedConversations.map((chat) => (
                <ChatListItem
                  key={chat.id}
                  {...chat}
                  active={chat.id === selectedChatId}
                  onSelect={() => setSelectedChatId(chat.id)}
                />
              ))}
            {tab === "groups" && groupsLoading && (
              <div className="flex justify-center py-8"><p className="text-sm text-muted-foreground">Loading groups...</p></div>
            )}
            {tab === "groups" && groupsError && (
              <div className="flex justify-center py-8"><p className="text-sm text-destructive">Failed to load groups</p></div>
            )}
            {tab === "groups" && !groupsLoading && !groupsError && groups.length === 0 && (
              <div className="flex flex-col items-center justify-center gap-3 py-12 px-4">
                <Users size={40} className="text-muted-foreground/40" />
                <p className="text-sm text-muted-foreground">
                  {user?.role === "Church Owner" ? "Create your first group" : "No groups yet"}
                </p>
              </div>
            )}
            {tab === "groups" &&
              groups.map((group) => (
                <ChatListItem
                  key={group?.id}
                  id={group?.id ?? ""}
                  name={group?.name ?? "Group"}
                  initials={group?.name?.slice(0, 2).toUpperCase() ?? "G"}
                  time={
                    group?.updatedAt
                      ? new Date(group.updatedAt).toLocaleTimeString([], {
                        hour: "2-digit",
                        minute: "2-digit",
                      })
                      : ""
                  }
                  lastMsg={`${group?._count?.comments ?? 0} messages · ${group?.church?.name ?? ""}`}
                  unread={0}
                  online={false}
                  active={group?.id === selectedGroupId}
                  onSelect={() => {
                    setSelectedGroupId(group?.id)
                    setSelectedChatId(null)
                  }}
                />
              ))}
          </div>
        </aside>

        {tab === "direct" && selectedConv ? (
          <ChatThread
            id={selectedConv.id}
            initialHeaderName={selectedConv.otherParticipant?.fullName}
            initialHeaderInitials={selectedConv.otherParticipant?.initials}
            initialHeaderOnline={selectedConv.otherParticipant?.isOnline}
            initialHeaderStatusText={
              selectedConv.otherParticipant?.isOnline
                ? "Active now"
                : selectedConv.otherParticipant?.lastSeenText ?? "Offline"
            }
          />
        ) : tab === "groups" && selectedGroup ? (
          <ChatThread
            id={selectedGroup.id}
            isGroup
            initialHeaderName={selectedGroup.name ?? "Group"}
            initialHeaderInitials={selectedGroup.name?.slice(0, 2).toUpperCase() ?? "G"}
            initialHeaderStatusText="Group"
          />
        ) : (
          <div className="hidden flex-1 items-center justify-center lg:flex">
            <p className="text-sm text-muted-foreground">
              {tab === "direct" ? "Select a conversation" : "Select or create a group"}
            </p>
          </div>
        )}
      </div>

      {user?.role === "Church Owner" && (
        <Link
          href="/chats/new-group"
          className="absolute bottom-4 right-4 flex size-12 items-center justify-center rounded-full bg-primary text-primary-foreground shadow-lg lg:hidden"
        >
          <CirclePlus size={28} />
        </Link>
      )}
    </div>
  )
}
