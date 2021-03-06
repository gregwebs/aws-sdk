{-# LANGUAGE FlexibleContexts #-}

module AWS.EC2.Region
    ( describeRegions
    ) where

import Data.Text (Text)

import Data.XML.Types (Event)
import Data.Conduit
import Control.Monad.Trans.Control (MonadBaseControl)
import Control.Applicative

import AWS.EC2.Internal
import AWS.EC2.Types
import AWS.EC2.Query
import AWS.Lib.Parser

describeRegions
    :: (MonadResource m, MonadBaseControl IO m)
    => [Text] -- ^ RegionNames
    -> [Filter] -- ^ Filters
    -> EC2 m (ResumableSource m Region)
describeRegions regions filters =
    ec2QuerySource "DescribeRegions" params regionInfoConduit
  where
    params =
        [ ArrayParams "RegionName" regions
        , FilterParams filters
        ]
    regionInfoConduit :: MonadThrow m
        => GLConduit Event m Region
    regionInfoConduit = itemConduit "regionInfo" $
        Region
        <$> getT "regionName"
        <*> getT "regionEndpoint"
