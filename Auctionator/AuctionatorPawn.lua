--[[
    AuctionatorPawn.lua

    PAWN integration module for Auctionator
    Provides functionality to display and sort by PAWN scores
]]--

local AuctionatorPawn = {};

-- Cache for PAWN scores to avoid repeated calculations
local scoreCache = {};
local cacheVersion = 0;

-- Initialize PAWN integration
function AuctionatorPawn:Initialize()
    self.isAvailable = (PawnGetItemValue ~= nil);
    self.scaleList = nil;

    if self.isAvailable then
        self:RefreshScaleList();
    end
end

-- Check if PAWN addon is loaded and available
function AuctionatorPawn:IsAvailable()
    return (PawnGetItemValue ~= nil);
end

-- Refresh the list of available PAWN scales
function AuctionatorPawn:RefreshScaleList()
    self.scaleList = {};

    if not self:IsAvailable() then
        return self.scaleList;
    end

    -- PAWN stores scales in PawnOptions.Scales table
    if PawnOptions and PawnOptions.Scales then
        for scaleName, scaleData in pairs(PawnOptions.Scales) do
            if scaleData and not scaleData.UnusableForClass then
                table.insert(self.scaleList, scaleName);
            end
        end

        -- Sort alphabetically for consistent display
        table.sort(self.scaleList);
    end

    return self.scaleList;
end

-- Get the list of available PAWN scale names
function AuctionatorPawn:GetScaleList()
    if not self.scaleList then
        self:RefreshScaleList();
    end
    return self.scaleList or {};
end

-- Get the currently configured scale name from settings
function AuctionatorPawn:GetConfiguredScale()
    if not AUCTIONATOR_PAWN_SCALE then
        -- Default to first available scale
        local scales = self:GetScaleList();
        if scales and #scales > 0 then
            return scales[1];
        end
        return nil;
    end
    return AUCTIONATOR_PAWN_SCALE;
end

-- Set the configured scale name
function AuctionatorPawn:SetConfiguredScale(scaleName)
    AUCTIONATOR_PAWN_SCALE = scaleName;
    self:ClearCache();
end

-- Clear the score cache (called when scale changes or on refresh)
function AuctionatorPawn:ClearCache()
    scoreCache = {};
    cacheVersion = cacheVersion + 1;
end

-- Get PAWN score for an item using the configured scale
function AuctionatorPawn:GetItemScore(itemLink)
    if not self:IsAvailable() or not itemLink then
        return nil;
    end

    -- Check cache first
    local cacheKey = itemLink .. ":" .. (self:GetConfiguredScale() or "default");
    if scoreCache[cacheKey] then
        return scoreCache[cacheKey];
    end

    -- Get score from PAWN
    local scaleName = self:GetConfiguredScale();
    local score = nil;

    -- Use correct PAWN API pattern: PawnGetItemData first, then PawnGetSingleValueFromItem
    if PawnGetItemData then
        -- Step 1: Get item table from PAWN (pass itemLink string)
        local itemTable = PawnGetItemData(itemLink);

        if not itemTable then
            return nil;
        end

        -- Step 2: Get score using item table and scale
        if scaleName and PawnGetSingleValueFromItem then
            score = PawnGetSingleValueFromItem(itemTable, scaleName);
        elseif PawnGetItemValue then
            score = PawnGetItemValue(itemTable);
        end
    end

    -- Only cache non-nil scores to prevent permanent nil caching
    if score then
        scoreCache[cacheKey] = score;
    end

    return score;
end

-- Format PAWN score for display
function AuctionatorPawn:FormatScore(score)
    if not score or score == 0 then
        return "";
    end

    -- Format with 1 decimal place, or no decimals if it's a whole number
    if score == math.floor(score) then
        return string.format("%d", score);
    else
        return string.format("%.1f", score);
    end
end

-- Get color for PAWN score display
function AuctionatorPawn:GetScoreColor(score)
    if not score or score == 0 then
        return 0.5, 0.5, 0.5;  -- Gray for no score
    elseif score >= 100 then
        return 0, 1, 0;  -- Green for high scores
    elseif score >= 50 then
        return 1, 1, 0;  -- Yellow for medium scores
    else
        return 1, 0.5, 0;  -- Orange for low scores
    end
end

-- Store in global namespace for access by other Auctionator files
_G.AuctionatorPawn = AuctionatorPawn;
