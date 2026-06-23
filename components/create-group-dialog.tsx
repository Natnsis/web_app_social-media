"use client"

import { useState, useEffect, useRef } from "react"
import { useRouter } from "next/navigation"
import { Avatar, AvatarFallback } from "@/components/ui/avatar"
import { Badge } from "@/components/ui/badge"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Textarea } from "@/components/ui/textarea"
import { Switch } from "@/components/ui/switch"
import { Separator } from "@/components/ui/separator"
import { ScrollArea } from "@/components/ui/scroll-area"
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogDescription,
  DialogFooter,
} from "@/components/ui/dialog"
import { useCreateGroup, useUpdateGroup, useDeleteGroup, useGroupMembers } from "@/hooks/use-groups"
import { ImagePlus, Trash, Users } from "nasicon-react/outline"
import type { MinimalGroup } from "@/types"

function getInitials(name: string) {
  return name
    .split(" ")
    .map((n) => n[0])
    .join("")
    .toUpperCase()
    .slice(0, 2)
}

interface CreateGroupDialogProps {
  open: boolean
  onOpenChange: (open: boolean) => void
  group?: MinimalGroup | null
}

export function CreateGroupDialog({
  open,
  onOpenChange,
  group,
}: CreateGroupDialogProps) {
  const router = useRouter()
  const isEdit = !!group
  const fileInputRef = useRef<HTMLInputElement>(null)

  const [name, setName] = useState("")
  const [description, setDescription] = useState("")
  const [isPrivate, setIsPrivate] = useState(true)
  const [imageFile, setImageFile] = useState<File | null>(null)
  const [imagePreview, setImagePreview] = useState<string | null>(null)
  const [error, setError] = useState<string | null>(null)
  const [deleteConfirm, setDeleteConfirm] = useState(false)

  const createGroup = useCreateGroup()
  const updateGroup = useUpdateGroup()
  const deleteGroup = useDeleteGroup()
  const { data: membersData } = useGroupMembers(isEdit ? group.id : null)
  const members = membersData?.data ?? []

  useEffect(() => {
    if (!open) return
    if (group) {
      setName(group.name)
      setDescription(group.description ?? "")
      setIsPrivate(group.isPrivate)
      setImagePreview(group.coverImageUrl)
    } else {
      setName("")
      setDescription("")
      setIsPrivate(true)
      setImageFile(null)
      setImagePreview(null)
    }
    setError(null)
    setDeleteConfirm(false)
  }, [open, group])

  function handleImageSelect(e: React.ChangeEvent<HTMLInputElement>) {
    const file = e.target.files?.[0]
    if (!file) return
    if (!file.type.startsWith("image/")) {
      setError("Only image files are allowed")
      return
    }
    setImageFile(file)
    setImagePreview(URL.createObjectURL(file))
    setError(null)
  }

  function handleRemoveImage() {
    setImageFile(null)
    setImagePreview(null)
    if (fileInputRef.current) fileInputRef.current.value = ""
  }

  async function handleSubmit() {
    if (!name.trim()) {
      setError("Group name is required")
      return
    }
    setError(null)

    const fd = new FormData()
    fd.append("name", name.trim())
    fd.append("description", description.trim())
    fd.append("isPrivate", String(isPrivate))
    if (imageFile) fd.append("image", imageFile)

    try {
      if (isEdit) {
        await updateGroup.mutateAsync({ id: group.id, formData: fd })
        onOpenChange(false)
      } else {
        const res = await createGroup.mutateAsync(fd)
        onOpenChange(false)
        router.push(`/chats/${res.data.id}?type=group`)
      }
    } catch (e: any) {
      setError(e.message || "Failed to save group")
    }
  }

  async function handleDelete() {
    if (!group) return
    try {
      await deleteGroup.mutateAsync(group.id)
      onOpenChange(false)
    } catch (e: any) {
      setError(e.message || "Failed to delete group")
    }
  }

  const isPending = createGroup.isPending || updateGroup.isPending || deleteGroup.isPending

  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      <DialogContent className="max-w-md sm:max-w-lg gap-0 p-0">
        <DialogHeader className="p-6 pb-0">
          <DialogTitle>{isEdit ? "Edit Group" : "Create Group"}</DialogTitle>
          <DialogDescription>
            {isEdit ? "Update group details and settings" : "Create a new ministry group"}
          </DialogDescription>
        </DialogHeader>

        <ScrollArea className="max-h-[70vh]">
          <div className="p-6 space-y-5">
            {error && (
              <div className="rounded-2xl bg-destructive/10 p-4 text-sm text-destructive">
                {error}
              </div>
            )}

            <div>
              <p className="mb-2 text-sm font-semibold">Cover Image</p>
              {imagePreview ? (
                <div className="relative aspect-video overflow-hidden rounded-2xl bg-muted">
                  <img
                    src={imagePreview}
                    alt="Group cover"
                    className="size-full object-cover"
                  />
                  <button
                    type="button"
                    onClick={handleRemoveImage}
                    className="absolute top-2 right-2 flex size-8 items-center justify-center rounded-full bg-black/50 text-white hover:bg-black/70"
                  >
                    <Trash size={14} />
                  </button>
                </div>
              ) : (
                <button
                  type="button"
                  onClick={() => fileInputRef.current?.click()}
                  className="flex w-full flex-col items-center gap-2 rounded-2xl border-2 border-dashed border-border py-8 hover:bg-muted/50 transition-colors"
                >
                  <div className="flex size-14 items-center justify-center rounded-full bg-blue-50 dark:bg-blue-950">
                    <ImagePlus size={24} className="text-primary" />
                  </div>
                  <p className="text-sm font-semibold">Upload Cover Image</p>
                  <p className="text-xs text-muted-foreground">Recommended: 16:9 Aspect Ratio</p>
                </button>
              )}
              <input
                ref={fileInputRef}
                type="file"
                accept="image/*"
                onChange={handleImageSelect}
                className="hidden"
              />
            </div>

            <div className="space-y-1.5">
              <label className="text-sm font-medium">Group Name</label>
              <Input
                placeholder="e.g., New Sanctuary Sound System"
                value={name}
                onChange={(e) => setName(e.target.value)}
                className="h-12 rounded-xl px-4"
              />
            </div>

            <div className="space-y-1.5">
              <label className="text-sm font-medium">Description</label>
              <Textarea
                placeholder="Briefly describe the purpose of this group..."
                value={description}
                onChange={(e) => setDescription(e.target.value)}
                className="min-h-24 rounded-xl px-4 py-3"
              />
            </div>

            <Separator />

            <div>
              <p className="mb-3 text-sm font-semibold text-primary">Governance &amp; Privacy</p>
              <div className="flex items-center justify-between rounded-2xl border border-border bg-card px-4 py-3">
                <p className="text-sm font-semibold">Private Group</p>
                <Switch checked={isPrivate} onCheckedChange={setIsPrivate} />
              </div>
            </div>

            {isEdit && members.length > 0 && (
              <>
                <Separator />
                <div>
                  <p className="mb-2 text-xs font-semibold uppercase tracking-wider text-muted-foreground">
                    Members ({members.length})
                  </p>
                  <div className="space-y-2">
                    {members.map((m) => (
                      <div
                        key={m.id}
                        className="flex items-center gap-3 rounded-2xl border border-border bg-card p-3"
                      >
                        <Avatar size="sm">
                          <AvatarFallback className="bg-primary/20 text-primary text-xs font-bold">
                            {getInitials(m.user.fullName)}
                          </AvatarFallback>
                        </Avatar>
                        <div className="flex-1">
                          <p className="text-sm font-semibold">{m.user.fullName}</p>
                          <Badge variant="outline" className="text-[10px] mt-0.5">
                            {m.role}
                          </Badge>
                        </div>
                      </div>
                    ))}
                  </div>
                </div>
              </>
            )}
          </div>
        </ScrollArea>

        <DialogFooter className="p-6 pt-0 gap-2">
          {isEdit && (
            <Button
              variant="destructive"
              className="rounded-xl"
              onClick={() => setDeleteConfirm(true)}
              disabled={isPending}
            >
              <Trash size={15} />
              Delete
            </Button>
          )}
          <Button
            className="rounded-xl"
            onClick={handleSubmit}
            disabled={isPending}
          >
            {isPending
              ? "Saving..."
              : isEdit
                ? "Save Changes"
                : "Create Group"}
          </Button>
        </DialogFooter>
      </DialogContent>

      <Dialog open={deleteConfirm} onOpenChange={setDeleteConfirm}>
        <DialogContent className="max-w-sm gap-0 p-0">
          <div className="p-6 space-y-4">
            <DialogTitle>Delete Group</DialogTitle>
            <DialogDescription>
              Are you sure you want to delete this group? This action cannot be undone.
            </DialogDescription>
          </div>
          <DialogFooter className="p-6 pt-0 gap-2">
            <Button
              variant="outline"
              className="rounded-xl"
              onClick={() => setDeleteConfirm(false)}
            >
              Cancel
            </Button>
            <Button
              variant="destructive"
              className="rounded-xl"
              onClick={handleDelete}
              disabled={isPending}
            >
              {deleteGroup.isPending ? "Deleting..." : "Delete"}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </Dialog>
  )
}
