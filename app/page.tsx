import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar"
import { Badge } from "@/components/ui/badge"
import { Button } from "@/components/ui/button"
import { GridCircle, SearchAlt, Bell } from "nasicon-react/solid"
import {
  HouseChimneyBlank,
  Annotation,
  CirclePlay,
  User,
} from "nasicon-react/outline"

const page = () => {
  const lives = [
    {
      name: "Grace Church",
      img: "https://github.com/shadcn.png",
    },
    {
      name: "Grace Church",
      img: "https://github.com/shadcn.png",
    },
    {
      name: "Grace Church",
      img: "https://github.com/shadcn.png",
    },
    {
      name: "Grace Church",
      img: "https://github.com/shadcn.png",
    },
    {
      name: "Grace Church",
      img: "https://github.com/shadcn.png",
    },
    {
      name: "Grace Church",
      img: "https://github.com/shadcn.png",
    },
    {
      name: "Grace Church",
      img: "https://github.com/shadcn.png",
    },
  ]
  return (
    <div className="flex h-screen flex-col justify-between">
      <div className="flex flex-col gap-2">
        <div className="flex items-center justify-between">
          <Button variant={"ghost"}>
            <GridCircle />
          </Button>
          <h1>
            Faith<span className="text-primary">Connect</span>
          </h1>

          <div className="flex gap-2">
            <Button variant={"ghost"} size={"icon"}>
              <SearchAlt className="text-muted-foreground" />
            </Button>
            <Button variant={"ghost"} size={"icon"}>
              <Bell className="text-muted-foreground" />
            </Button>
          </div>
        </div>
        <div className="px-2">
          <div className="mb-2 flex items-center justify-between">
            <h1 className="font-bold text-primary">Live Now</h1>
            <Button
              className="border border-gray-300 text-primary"
              variant={"secondary"}
              size={"sm"}
            >
              VIEW ALL
            </Button>
          </div>
          <div className="flex gap-4 overflow-x-auto">
            {lives.map((l, index) => (
              <div key={index} className="relative">
                <Avatar className="z-10 h-15 w-15 border">
                  <AvatarImage src={l.img} />
                  <AvatarFallback>{l.name}</AvatarFallback>
                </Avatar>
                <div className="absolute bottom-0 left-1/2 z-20 flex -translate-x-1/2 justify-center">
                  <Badge className="flex bg-red-300/60">
                    <div className="h-1 w-1 rounded-full bg-red-700" />
                    <h1 className="text-white">LIVE</h1>
                  </Badge>
                </div>
              </div>
            ))}
          </div>
        </div>
      </div>

      <div className="flex-1 overflow-y-auto px-2 py-2">
        <div className="my-2 flex h-fit flex-col gap-2 rounded-lg bg-[url('/background.jpg')] px-2 py-4">
          <p className="text-sm text-white">DAILY VERSE</p>
          <p className="text-4xl font-bold text-white">
            "Be still, and know that I am God."
          </p>
          <p className="font-bold text-blue-400">
            psalm 46:10 - Meditate on peace today.
          </p>
        </div>

        <div className="flex flex-col gap-2">
          <div className="h-[20vh] border border-black"></div>
          <div className="h-[20vh] border border-black"></div>
          <div className="h-[20vh] border border-black"></div>
          <div className="h-[20vh] border border-black"></div>
          <div className="h-[20vh] border border-black"></div>
        </div>
      </div>

      <div className="flex justify-between px-5">
        <div className="flex flex-col items-center">
          <HouseChimneyBlank size={24} strokeWidth={1.5} />
          <h1>Home</h1>
        </div>

        <div className="flex flex-col items-center">
          <Annotation size={24} strokeWidth={1.5} />
          <h1>Chats</h1>
        </div>

        <div className="flex flex-col items-center">
          <CirclePlay size={24} strokeWidth={1.5} />
          <h1>Shorts</h1>
        </div>

        <div className="flex flex-col items-center">
          <User size={24} strokeWidth={1.5} />
          <h1>Accounts</h1>
        </div>
      </div>
    </div>
  )
}

export default page
