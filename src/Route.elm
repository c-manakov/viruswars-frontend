module Route exposing (Route(..), fromUrl, href, replaceUrl, routeToString, toUrl)

import Browser.Navigation as Nav
import Html exposing (Attribute)
import Html.Attributes as Attr
import Url exposing (Url)
import Url.Parser as Parser exposing ((</>), Parser, oneOf, s, string)



-- ROUTING


type Route
    = Home
    | Root
    | Room String
    | NotFound
    | Redirect Route


parser : Parser (Route -> a) a
parser =
    oneOf
        [ Parser.map Home Parser.top
        , Parser.map Room (s "room" </> string)
        , Parser.map NotFound (s "not-found")

        -- , Parser.map Profile (s "profile" </> Username.urlParser)
        -- , Parser.map Article (s "article" </> Slug.urlParser)
        ]



-- PUBLIC HELPERS


href : Route -> Attribute msg
href targetRoute =
    Attr.href (routeToString targetRoute)


replaceUrl : Nav.Key -> Route -> Cmd msg
replaceUrl key route =
    Nav.replaceUrl key (routeToString route)


fromUrl : Url -> Maybe Route
fromUrl url =
    -- The RealWorld spec treats the fragment like a path.
    -- This makes it *literally* the path, so we can proceed
    -- with parsing as if it had been a normal path all along.
    { url | path = Maybe.withDefault "" url.fragment, fragment = Nothing }
        |> Parser.parse parser


toUrl : Route -> Maybe Url
toUrl route =
    Url.fromString (routeToString route)



-- INTERNAL


routeToString : Route -> String
routeToString page =
    let
        pieces =
            case page of
                Home ->
                    []

                Root ->
                    []

                Room roomId ->
                    [ "room", roomId ]

                NotFound ->
                    [ "not-found" ]

                Redirect route ->
                    [ "redirect", routeToString route ]
    in
    "#/" ++ String.join "/" pieces
