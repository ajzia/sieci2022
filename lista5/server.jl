using HTTP, Sockets

const ROUTER = HTTP.Router()

println("The server is running...") 

function Base.print(header)
  top = "[ HEADER ]"
  pad = ""; for _ in 1:68 pad *= "=" end

  text = ""
  text *= ">" * pad * top * pad * "<\n"
  
  for head in header
    x = "> $(head[1]): $(head[2])"
    for _ in 1:(146-length(x))
      x *= " "
    end
    text *= x * " <\n"
  end
  return text * ">" * pad * pad * "==========<"
end

# Zmień skrypt (lub napisz własny serwer w dowolnym języku programowania) tak aby wysyłał do klienta nagłówek jego żądania.
HTTP.@register(ROUTER, "GET", "/header", req->HTTP.Response(200, "\n$(print(HTTP.Messages.headers(req)))"))


# Zmień skrypt (lub napisz własny serwer w dowolnym języku programowania) tak aby obsugiwał żądania klienta do prostego tekstowego 
# serwisu WWW (kilka statycznych ston z wzajemnymi odwołaniami) zapisanego w pewnym katalogu dysku lokalnego komputera na którym uruchomiony jest skrypt serwera.
HTTP.@register(ROUTER, "GET", "/", req->HTTP.Response(read("./main.html")))
HTTP.@register(ROUTER, "GET", "/back", req->HTTP.Response(read("./main.html")))

HTTP.@register(ROUTER, "GET", "/kultura", req->HTTP.Response(read("./kultura.html")))
HTTP.@register(ROUTER, "GET", "/shrek", req->HTTP.Response(read("./shrek.txt")))
HTTP.@register(ROUTER, "GET", "/popcat", req->HTTP.Response(read("./popcat.gif")))

HTTP.@register(ROUTER, "GET", "/zdjecia", req->HTTP.Response(read("./zdjecia.html")))
HTTP.@register(ROUTER, "GET", "/misiek", req->HTTP.Response(read("./misiek.jpg")))
HTTP.@register(ROUTER, "GET", "/gloryhammer", req->HTTP.Response(read("./gloryhammer.png")))

HTTP.@register(ROUTER, "GET", "/*", req->HTTP.Response(404, "Not found!"))

HTTP.serve(ROUTER, Sockets.localhost, 8888)
