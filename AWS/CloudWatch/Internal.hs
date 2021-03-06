{-# LANGUAGE FlexibleContexts, RankNTypes #-}

module AWS.CloudWatch.Internal
    where

import Data.ByteString (ByteString)
import Data.Text (Text)
import Data.Conduit
import Control.Monad.Trans.Control (MonadBaseControl)
import Data.Monoid ((<>))
import Data.XML.Types (Event(..))

import AWS.Class
import AWS.Lib.Query
import AWS.Lib.Parser

apiVersion :: ByteString
apiVersion = "2010-08-01"

type CloudWatch m a = AWS AWSContext m a

cloudWatchQuery
    :: (MonadBaseControl IO m, MonadResource m)
    => ByteString -- ^ Action
    -> [QueryParam]
    -> GLSink Event m a
    -> CloudWatch m a
cloudWatchQuery = commonQuery apiVersion

elements :: MonadThrow m
    => Text
    -> GLSink Event m a
    -> GLSink Event m [a]
elements name f = element (name <> "s") $ listConsumer name f
