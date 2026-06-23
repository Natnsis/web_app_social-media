"use client"

import { useCallback } from "react"
import { useRouter } from "next/navigation"
import { Avatar, AvatarImage, AvatarFallback } from "@/components/ui/avatar"
import { Badge } from "@/components/ui/badge"
import { Button } from "@/components/ui/button"
import { Separator } from "@/components/ui/separator"
import { ScrollArea } from "@/components/ui/scroll-area"
import {
  Dialog,
  DialogContent,
  DialogTitle,
  DialogDescription,
} from "@/components/ui/dialog"
import { useChurch } from "@/hooks/use-church"
import { apiStartConversation } from "@/lib/api/messaging"
import {
  Globe,
  Mail,
  Phone,
  MapPin,
  MessageSquare,
  Heart,
} from "nasicon-react/outline"

function getInitials(name: string) {
  return name
    .split(" ")
    .map((n) => n[0])
    .join("")
    .toUpperCase()
    .slice(0, 2)
}

interface ChurchProfileDialogProps {
  churchId: string
  open: boolean
  onOpenChange: (open: boolean) => void
}

export function ChurchProfileDialog({
  churchId,
  open,
  onOpenChange,
}: ChurchProfileDialogProps) {
  const router = useRouter()
  const { data, isLoading, isError } = useChurch(open ? churchId : null)
  const church = data?.data

  const handleMessageUser = useCallback(
    async (userId: string) => {
      onOpenChange(false)
      try {
        const res = await apiStartConversation(userId)
        router.push(`/chats?chatId=${res.data.conversationId}`)
      } catch {
        router.push("/chats")
      }
    },
    [router, onOpenChange],
  )

  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      <DialogContent className="max-w-md sm:max-w-lg gap-0 p-0">
        {isLoading ? (
          <div className="flex items-center justify-center py-16">
            <p className="text-sm text-muted-foreground">Loading church details...</p>
          </div>
        ) : isError || !church ? (
          <div className="flex items-center justify-center py-16">
            <p className="text-sm text-destructive">Failed to load church details</p>
          </div>
        ) : (
          <ScrollArea className="max-h-[85vh]">
            <div className="p-6 pt-14 space-y-5">
              <div className="flex flex-col items-center gap-3 text-center">
                <Avatar className="size-16 ring-4 ring-primary/20">
                  {church.logoUrl ? (
                    <AvatarImage src={church.logoUrl} alt={church.name} />
                  ) : null}
                  <AvatarFallback className="bg-primary/15 text-primary text-lg font-bold">
                    {getInitials(church.name)}
                  </AvatarFallback>
                </Avatar>
                <div>
                  <DialogTitle className="text-xl font-bold">
                    {church.name}
                  </DialogTitle>
                  {church.description && (
                    <DialogDescription className="mt-1 text-sm leading-relaxed">
                      {church.description}
                    </DialogDescription>
                  )}
                </div>
              </div>

              <div className="flex flex-wrap justify-center gap-2">
                <Badge variant="secondary" className="gap-1.5 px-3 py-1">
                  <Heart size={13} />
                  {church._count.followers} Followers
                </Badge>
                <Badge variant="secondary" className="gap-1.5 px-3 py-1">
                  {church._count.posts} Posts
                </Badge>
                <Badge variant="secondary" className="gap-1.5 px-3 py-1">
                  {church._count.shorts} Shorts
                </Badge>
              </div>

              {(church.websiteUrl || church.email || church.phoneNumber || church.address || church.city || church.country) && (
                <div className="space-y-2.5 rounded-2xl border border-border bg-card p-4">
                  {church.websiteUrl && (
                    <a
                      href={church.websiteUrl}
                      target="_blank"
                      rel="noopener noreferrer"
                      className="flex items-center gap-3 text-sm text-muted-foreground hover:text-primary transition-colors"
                    >
                      <Globe size={16} className="shrink-0" />
                      <span className="truncate">{church.websiteUrl}</span>
                    </a>
                  )}
                  {church.email && (
                    <div className="flex items-center gap-3 text-sm text-muted-foreground">
                      <Mail size={16} className="shrink-0" />
                      <span className="truncate">{church.email}</span>
                    </div>
                  )}
                  {church.phoneNumber && (
                    <div className="flex items-center gap-3 text-sm text-muted-foreground">
                      <Phone size={16} className="shrink-0" />
                      <span>{church.phoneNumber}</span>
                    </div>
                  )}
                  {(church.address || church.city || church.country) && (
                    <div className="flex items-center gap-3 text-sm text-muted-foreground">
                      <MapPin size={16} className="shrink-0" />
                      <span className="truncate">
                        {[church.address, church.city, church.country]
                          .filter(Boolean)
                          .join(", ")}
                      </span>
                    </div>
                  )}
                </div>
              )}

              {church.owner && (
                <>
                  <Separator />
                  <div>
                    <p className="mb-2 text-xs font-semibold uppercase tracking-wider text-muted-foreground">
                      Church Owner
                    </p>
                    <div className="flex items-center justify-between rounded-2xl border border-border bg-card p-3">
                      <div className="flex items-center gap-3">
                        <Avatar size="sm">
                          {church.owner.avatarUrl ? (
                            <AvatarImage src={church.owner.avatarUrl} alt={church.owner.fullName} />
                          ) : null}
                          <AvatarFallback className="bg-primary/20 text-primary text-xs font-bold">
                            {getInitials(church.owner.fullName)}
                          </AvatarFallback>
                        </Avatar>
                        <div>
                          <p className="text-sm font-semibold">{church.owner.fullName}</p>
                          <Badge className="text-[10px] mt-0.5">Owner</Badge>
                        </div>
                      </div>
                      <Button
                        variant="ghost"
                        size="sm"
                        className="gap-1.5 rounded-xl"
                        onClick={() => handleMessageUser(church.owner!.id)}
                      >
                        <MessageSquare size={15} />
                        Message
                      </Button>
                    </div>
                  </div>
                </>
              )}

              {church.moderators.length > 0 && (
                <>
                  <Separator />
                  <div>
                    <p className="mb-2 text-xs font-semibold uppercase tracking-wider text-muted-foreground">
                      Moderators ({church.moderators.length})
                    </p>
                    <div className="space-y-2">
                      {church.moderators.map((mod) => (
                        <div
                          key={mod.id}
                          className="flex items-center justify-between rounded-2xl border border-border bg-card p-3"
                        >
                          <div className="flex items-center gap-3">
                            <Avatar size="sm">
                              {mod.user.avatarUrl ? (
                                <AvatarImage src={mod.user.avatarUrl} alt={mod.user.fullName} />
                              ) : null}
                              <AvatarFallback className="bg-primary/20 text-primary text-xs font-bold">
                                {getInitials(mod.user.fullName)}
                              </AvatarFallback>
                            </Avatar>
                            <p className="text-sm font-semibold">{mod.user.fullName}</p>
                          </div>
                          <Button
                            variant="ghost"
                            size="sm"
                            className="gap-1.5 rounded-xl"
                            onClick={() => handleMessageUser(mod.userId)}
                          >
                            <MessageSquare size={15} />
                            Message
                          </Button>
                        </div>
                      ))}
                    </div>
                  </div>
                </>
              )}
            </div>
          </ScrollArea>
        )}
      </DialogContent>
    </Dialog>
  )
}
