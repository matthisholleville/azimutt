module Pages.PwaStart exposing (Model, Msg, page)

import Components.Atoms.Loader as Loader
import Gen.Params.PwaStart exposing (Params)
import Gen.Route as Route
import Libs.Maybe as Maybe
import Page
import Ports exposing (JsMsg(..))
import Request
import Shared
import Time
import View exposing (View)


page : Shared.Model -> Request.With Params -> Page.With Model Msg
page _ req =
    Page.element
        { init = init
        , update = update req
        , view = view
        , subscriptions = subscriptions
        }


type alias Model =
    {}


type Msg
    = JsMessage JsMsg



-- INIT


init : ( Model, Cmd Msg )
init =
    ( {}
    , Cmd.batch
        [ Ports.setClasses { html = "h-full", body = "h-full" }
        , Ports.trackPage "pwa-start"
        , Ports.loadProjects
        ]
    )



-- UPDATE


update : Request.With Params -> Msg -> Model -> ( Model, Cmd Msg )
update req msg model =
    case msg of
        JsMessage (GotProjects ( _, projects )) ->
            ( model
            , Request.pushRoute
                (projects
                    |> List.sortBy (\p -> negate (Time.posixToMillis p.updatedAt))
                    |> List.head
                    |> Maybe.mapOrElse (\p -> Route.Projects__Id_ { id = p.id }) Route.Projects
                )
                req
            )

        JsMessage _ ->
            ( model, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Ports.onJsMessage JsMessage



-- VIEW


view : Model -> View Msg
view _ =
    { title = "Azimutt is loading..."
    , body = [ Loader.fullScreen ]
    }
