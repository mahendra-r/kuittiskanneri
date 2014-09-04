module Main where

-- Vaatii TagSoup moduulin
-- cabal install tagsoup

import Data.List (isPrefixOf)
import Data.Maybe (fromMaybe)
import Network.HTTP
import Control.Monad
import Text.HTML.TagSoup

-- | Avaa urlin ja kaivaa vastauksesta sisällön
openUrl :: String -> IO String
openUrl url = simpleHTTP (getRequest url) >>= getResponseBody

-- | Kerää nettisivulta kaikki linkit, joiden href alkaa merkkijonolla "tuotteet"
scrapeProductLinksHrefs :: String -> IO [String]
scrapeProductLinksHrefs = liftM (map getHref . filter productLink) . fmap parseTags . openUrl
    where
        -- Ottaa tagista hrefin arvon talteen
        getHref :: Tag String -> String
        getHref (TagOpen "a" attributes) = fromMaybe "" $ lookup "href" attributes

        -- Palauttaa True, jos tagi on linkki, ja sen hrefin alussa on "tuotteet"
        productLink :: Tag String -> Bool
        productLink (TagOpen "a" attributes) = any (\(_, value) -> "tuotteet" `isPrefixOf` value) attributes
        productLink _                        = False

main :: IO ()
main = mapM_ putStrLn =<< scrapeProductLinksHrefs "http://www.rainbow.fi/rainbow-tuotteet/selaa-tuotteita/"