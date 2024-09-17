hooksecurefunc(AddonCompartmentFrame, "UpdateDisplay", function()
    DBisShown = DBisShown == nil and true or DBisShown
    AddonCompartmentButtonsFrame:Init()
    AddonCompartmentButtonsFrame.Contents:SetShown(DBisShown)
    AddonCompartmentButtonsFrame.Drag:SetArrow(DBisShown)
end)

AddonCompartmentButtonsMixin = {}

function AddonCompartmentButtonsMixin:OnLoad()
    self.iconSize = 16
	self.spacer = 4
	self.iconSpace = self.iconSize + self.spacer
    self.cols = 10
    self.rows = 2
    self.inset = 4
    self.pool = CreateFramePool("Button", self.Contents, "AddonCompartmentButtonsButtonFrame");
    self:SetWidth(self.iconSpace * self.cols+ (self.inset*2))
    self:SetHeight(self.iconSpace * self.rows + (self.inset*2))

    local dragarea = self.Drag
    self:SetMovable(true)
    dragarea:EnableMouse(true)
    dragarea:RegisterForDrag("LeftButton")
    dragarea:SetScript("OnDragStart", function(self, button)
        AddonCompartmentButtonsFrame:StartMoving()
    end)

    dragarea:SetScript("OnDragStop", function(self)
        AddonCompartmentButtonsFrame:StopMovingOrSizing()
    end)
end

function AddonCompartmentButtonsMixin:getPos(type, index)
    index = index -1
    local row = math.floor(index / self.cols) 
    if type == "y" then return row * self.iconSpace + (self.spacer/2) + self.inset end
    return ((index - (row * self.cols)) * self.iconSpace) + (self.spacer/2) + self.inset
end

function AddonCompartmentButtonsMixin:Init()
    self.pool:ReleaseAll();
    local registeredAddons =  AddonCompartmentFrame.registeredAddons

    local width = #registeredAddons < self.cols and #registeredAddons or self.cols
    self.rows = math.ceil(#registeredAddons/self.cols)
    self:SetWidth(self.iconSpace * width)
    self:SetHeight(self.iconSpace * self.rows)

    for key, value in pairs(registeredAddons) do
        local texture = value.icon or [[Interface\ICONS\INV_Misc_QuestionMark]]
        local iconButton = self.pool:Acquire()
        iconButton:SetPoint("TOPLEFT", self:getPos("x", key), self:getPos("y", key) * -1)
        iconButton.data = value
        iconButton.Icon:SetTexture(texture)
        iconButton:RegisterForClicks("AnyDown")
        iconButton:SetSize( self.iconSize, self.iconSize)
        iconButton:Show()
    end

    self:Show()
end


AddonCompartmentButtonsDragMixin = {}

function AddonCompartmentButtonsDragMixin:OnLoad()
    TooltipBackdropTemplateMixin.TooltipBackdropOnLoad(self)
    self.Arrow:SetRotation(math.pi/2)
end
function AddonCompartmentButtonsDragMixin:OnClick()
    DBisShown = not DBisShown
    self:SetArrow(DBisShown)
end

function AddonCompartmentButtonsDragMixin:SetArrow(state)
    AddonCompartmentButtonsFrame.Contents:SetShown(state)
   local rotate = DBisShown and math.pi/2 or -math.pi/2
   self.Arrow:SetRotation(rotate)
end


AddonCompartmentButtonsButtonMixin = {}

function AddonCompartmentButtonsButtonMixin:OnClick(button)
    if not self.data.func then  return end
    self.data.func(nil, { buttonName = button }, nil)
end

function AddonCompartmentButtonsButtonMixin:OnEnter()
    if self.data.funcOnEnter then 
        do
            self.data.funcOnEnter(self)
        end
        return
    end
    if not self.data.text then return end
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
	GameTooltip:AddLine(self.data.text)
	GameTooltip:Show()
end


function AddonCompartmentButtonsButtonMixin:OnLeave()
    if self.data.funcOnLeave then 
        do
            self.data.funcOnLeave(self)
        end
        return
    end
    GameTooltip:Hide()
end