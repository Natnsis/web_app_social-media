"use client"

import { useCallback, useMemo, useState } from "react"
import { useRouter } from "next/navigation"
import Image from "next/image"
import { useJsApiLoader, GoogleMap, Marker } from "@react-google-maps/api"
import { Avatar, AvatarFallback } from "@/components/ui/avatar"
import { Button } from "@/components/ui/button"
import { Dialog, DialogTrigger, DialogContent, DialogHeader, DialogTitle, DialogFooter } from "@/components/ui/dialog"
import { useGeolocation } from "@/hooks/use-geolocation"
import { useNearbyChurches, useToggleFollowChurch } from "@/hooks/use-nearby-churches"
import { LocationPin, ArrowLeft, SlidersSimple } from "nasicon-react/outline"
import type { NearbyChurch } from "@/lib/api/churches"

const RADIUS_OPTIONS = [10, 25, 50, 100, 250]

function getInitials(name: string) {
  return name
    .split(" ")
    .map((n) => n[0])
    .join("")
    .toUpperCase()
    .slice(0, 2)
}

function ChurchCard({
  church,
  following,
  onToggle,
}: {
  church: NearbyChurch
  following: boolean
  onToggle: (id: string) => void
}) {
  return (
    <div className="flex items-center gap-3 rounded-xl border border-border bg-card p-3">
      <Avatar size="lg" className="shrink-0">
        {church.logoUrl ? (
          <Image src={church.logoUrl} alt={church.name} width={40} height={40} className="rounded-full object-cover" unoptimized />
        ) : (
          <AvatarFallback className="bg-primary/20 text-primary text-xs font-semibold">
            {getInitials(church.name)}
          </AvatarFallback>
        )}
      </Avatar>
      <div className="flex min-w-0 flex-1 flex-col gap-0.5">
        <p className="truncate text-sm font-bold">{church.name}</p>
        <p className="flex items-center gap-1 truncate text-xs text-muted-foreground">
          <LocationPin size={12} className="shrink-0 text-primary" />
          {church.address}
        </p>
        <p className="text-xs text-muted-foreground">{church.distance.toFixed(1)} km away</p>
      </div>
      <Button
        variant={following ? "outline" : "default"}
        size="xs"
        className="shrink-0 rounded-full"
        onClick={() => onToggle(church.id)}
      >
        {following ? "Following" : "Follow"}
      </Button>
    </div>
  )
}

export default function NearbyChurchesPage() {
  const router = useRouter()
  const { latitude, longitude, loading: geoLoading } = useGeolocation()
  const [radius, setRadius] = useState(50)
  const [pendingRadius, setPendingRadius] = useState(50)
  const [dialogOpen, setDialogOpen] = useState(false)
  const [followed, setFollowed] = useState<Set<string>>(new Set())
  const toggleFollow = useToggleFollowChurch()

  const { data, isLoading, isError, refetch } = useNearbyChurches(latitude, longitude, radius)
  const churches = data?.data ?? []

  const { isLoaded } = useJsApiLoader({
    id: "google-map-script",
    googleMapsApiKey: process.env.NEXT_PUBLIC_GOOGLE_MAP_KEY ?? "",
  })

  const center = useMemo(() => ({ lat: latitude, lng: longitude }), [latitude, longitude])

  const handleToggleFollow = useCallback(
    (id: string) => {
      const isFollowing = followed.has(id)
      setFollowed((prev) => {
        const next = new Set(prev)
        if (isFollowing) next.delete(id)
        else next.add(id)
        return next
      })
      toggleFollow.mutate({ id, following: isFollowing })
    },
    [followed, toggleFollow]
  )

  const mapContainerStyle = { width: "100%", height: "100%" }

  const listContent = (
    <>
      <div className="border-b border-border bg-background px-4 py-3">
        <p className="text-sm font-semibold">
          {isLoading ? "Loading..." : `${churches.length} church${churches.length !== 1 ? "es" : ""} found below`}
        </p>
        <p className="text-xs text-muted-foreground">Ethiopia &mdash; within {radius} km</p>
      </div>

      <div className="flex-1 space-y-3 overflow-y-auto px-4 pb-6 pt-3">
        {isLoading && (
          <>
            {[1, 2, 3].map((i) => (
              <div key={i} className="flex animate-pulse items-center gap-3 rounded-xl border border-border bg-card p-3">
                <div className="size-10 shrink-0 rounded-full bg-muted" />
                <div className="flex-1 space-y-2">
                  <div className="h-4 w-40 rounded bg-muted" />
                  <div className="h-3 w-32 rounded bg-muted" />
                </div>
                <div className="h-6 w-20 rounded-full bg-muted" />
              </div>
            ))}
          </>
        )}

        {isError && (
          <div className="flex flex-col items-center gap-3 rounded-xl border border-border bg-card p-8 text-center">
            <p className="text-sm text-muted-foreground">Couldn&apos;t load nearby churches</p>
            <Button variant="outline" size="sm" onClick={() => refetch()}>
              Try again
            </Button>
          </div>
        )}

        {!isLoading && !isError && churches.length === 0 && (
          <div className="flex flex-col items-center gap-3 rounded-xl border border-border bg-card p-8 text-center">
            <p className="text-sm text-muted-foreground">No churches found within {radius} km</p>
            <Button variant="outline" size="sm" onClick={() => { setRadius(100); setPendingRadius(100) }}>
              Increase radius to 100 km
            </Button>
          </div>
        )}

        {!isLoading && !isError && churches.map((church) => (
          <ChurchCard
            key={church.id}
            church={church}
            following={followed.has(church.id)}
            onToggle={handleToggleFollow}
          />
        ))}
      </div>
    </>
  )

  return (
    <div className="flex h-full flex-col">
      {/* Header */}
      <header className="flex shrink-0 items-center justify-between border-b border-border bg-background px-4 py-3">
        <div className="flex items-center gap-3">
          <Button variant="ghost" size="icon-sm" className="rounded-lg" onClick={() => router.back()}>
            <ArrowLeft size={20} />
          </Button>
          <h1 className="text-lg font-bold">Nearby</h1>
        </div>
        <Dialog open={dialogOpen} onOpenChange={(open) => { setDialogOpen(open); if (open) setPendingRadius(radius) }}>
          <DialogTrigger render={<Button variant="outline" size="sm" className="gap-2 rounded-full" />}>
            <SlidersSimple size={16} />
            <span>{radius} km</span>
          </DialogTrigger>
          <DialogContent className="sm:max-w-xs">
            <DialogHeader>
              <DialogTitle>Change Radius</DialogTitle>
            </DialogHeader>
            <div className="flex flex-col gap-2">
              {RADIUS_OPTIONS.map((r) => (
                <button
                  key={r}
                  onClick={() => setPendingRadius(r)}
                  className={`flex items-center justify-between rounded-xl border px-4 py-3 text-sm font-medium transition-colors ${
                    pendingRadius === r
                      ? "border-primary bg-primary/10 text-primary"
                      : "border-border hover:bg-muted"
                  }`}
                >
                  <span>{r} km</span>
                  {pendingRadius === r && (
                    <span className="flex size-5 items-center justify-center rounded-full bg-primary text-[11px] text-primary-foreground">
                      ✓
                    </span>
                  )}
                </button>
              ))}
            </div>
            <DialogFooter>
              <Button variant="ghost" onClick={() => setDialogOpen(false)}>
                Cancel
              </Button>
              <Button
                onClick={() => {
                  setRadius(pendingRadius)
                  setDialogOpen(false)
                }}
              >
                Apply
              </Button>
            </DialogFooter>
          </DialogContent>
        </Dialog>
      </header>

      {/* Desktop layout */}
      <div className="hidden h-full flex-1 lg:flex">
        <div className="relative h-full flex-1">
          {isLoaded && !geoLoading ? (
            <GoogleMap mapContainerStyle={mapContainerStyle} center={center} zoom={12} options={{ disableDefaultUI: false, zoomControl: true, streetViewControl: false, mapTypeControl: false }}>
              <Marker position={center} label={{ text: "You", fontWeight: "bold" }} />
              {churches.map((church) => (
                <Marker
                  key={church.id}
                  position={{ lat: church.latitude, lng: church.longitude }}
                  title={church.name}
                />
              ))}
            </GoogleMap>
          ) : (
            <div className="flex h-full items-center justify-center bg-muted text-sm text-muted-foreground">
              Loading map...
            </div>
          )}
        </div>
        <div className="flex w-[400px] shrink-0 flex-col border-l border-border bg-background">
          {listContent}
        </div>
      </div>

      {/* Mobile layout */}
      <div className="relative flex flex-1 flex-col lg:hidden">
        <div className="sticky top-0 z-10 h-[40vh] min-h-[200px] bg-muted">
          {isLoaded && !geoLoading ? (
            <GoogleMap mapContainerStyle={mapContainerStyle} center={center} zoom={12} options={{ disableDefaultUI: true, zoomControl: false, streetViewControl: false, mapTypeControl: false }}>
              <Marker position={center} label={{ text: "You", fontWeight: "bold" }} />
              {churches.map((church) => (
                <Marker
                  key={church.id}
                  position={{ lat: church.latitude, lng: church.longitude }}
                  title={church.name}
                />
              ))}
            </GoogleMap>
          ) : (
            <div className="flex h-full items-center justify-center text-sm text-muted-foreground">
              Loading map...
            </div>
          )}
        </div>
        <div className="relative z-20 -mt-6 flex flex-1 flex-col rounded-t-2xl bg-background">
          {listContent}
        </div>
      </div>
    </div>
  )
}
