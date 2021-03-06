{-# LANGUAGE DataKinds             #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE OverloadedStrings     #-}
{-# LANGUAGE TypeApplications      #-}
{-# LANGUAGE TypeFamilies          #-}
module Frontend
  ( frontend
  , headStatic
  , body
  ) where

import           System.Random        (StdGen)

import           Data.Semigroup       ((<>))
import Data.Text (Text)

import           Reflex.Dom.Core

import           WebGL.GOL            (gol)

import           Canvas2D.JoyDivision (joyDivision)
import           Canvas2D.TiledLines  (tiledLines)

import           SVG.Squares              (squares)

import qualified Styling.Bootstrap    as B

import           Static

widg
  :: MonadWidget t m
  => m ()
  -> Text
  -> m (Event t (m ()))
widg w txt = 
  (w <$) <$> B.bsButton_ txt B.Primary

body :: StdGen -> Widget x ()
body sGen = do
  divClass "container" $
    divClass "row" $ do
    eWidgs <- divClass "col-2" $ sequenceA 
      [ widg (squares sGen) "Squares" 
      , widg tiledLines "Tiled Lines" 
      , widg (joyDivision sGen) "Joy Division" 
      , widg (gol sGen) "Game Of Life"
      ]

    _ <- 
      divClass "col-10"
      . divClass "container"
        . divClass "row" $ widgetHold (squares sGen) (leftmost eWidgs)
    blank
  blank

headStatic :: StaticWidget x ()
headStatic = do
  cssLink (static @"css/reflexive-art.css")
  cssLink "css/bootstrap.min.css"
  el "title" $ text "Oh my"
  where
    cssLink ss = elAttr "link" ("rel" =: "stylesheet" <> "href" =: ss) blank

frontend :: StdGen -> (StaticWidget x (), Widget x ())
frontend sGen =
  ( headStatic
  , body sGen
  )
