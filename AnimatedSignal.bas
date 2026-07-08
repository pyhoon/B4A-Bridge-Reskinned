B4A=true
Group=Bridge
ModulesStructureVersion=1
Type=Class
Version=1.0
@EndOfDesignText@
#Region Custom View Attributes
#DesignerProperty: Key: State, DisplayName: Initial State, FieldType: String, DefaultValue: idle, List: idle|scanning|connected
#End Region

Sub Class_Globals
	Private mEventName As String 'ignore
	Private mCallBack As Object 'ignore
	Private mBase As Panel
	Private mBar(4) As Panel
	Private mTimer As Timer
	Private mPhase As Float = 0
	Private mState As String = "idle"
End Sub

Public Sub Initialize (Callback As Object, EventName As String)
	mEventName = EventName
	mCallBack = Callback
	mTimer.Initialize("mTimer", 60)
End Sub

Public Sub DesignerCreateView (Base As Panel, Lbl As Label, Props As Map)
	mBase = Base
	mBase.Color = Colors.Transparent
	mState = Props.GetDefault("State", "idle")
	CreateBars
	mTimer.Enabled = True
End Sub

Private Sub CreateBars
	Dim barCount As Int = 4
	Dim w As Float = mBase.Width
	Dim h As Float = mBase.Height
	If w < 10 Or h < 10 Then Return
	Dim barW As Float = w / (barCount * 2.5 + 0.5)
	Dim gap As Float = barW * 0.7
	Dim totalW As Float = barCount * barW + (barCount - 1) * gap
	Dim startX As Float = (w - totalW) / 2
	Dim baseY As Float = h - 3
	For i = 0 To barCount - 1
		Dim barH As Float = (h - 6) * ((i + 1) / barCount) * 0.8
		Dim x As Float = startX + (barW + gap) * i
		Dim y As Float = baseY - barH
		mBar(i).Initialize("")
		mBar(i).Color = 0xFFE5E7EB
		mBase.AddView(mBar(i), x, y, barW, barH)
	Next
End Sub

Public Sub GetBase As Panel
	Return mBase
End Sub

Public Sub SetState (State As String)
	mState = State
End Sub

Sub mTimer_Tick
	mPhase = mPhase + 0.12
	If mPhase > 2 * 3.14159 Then mPhase = 0
	Dim barCount As Int = 4
	Dim sweep As Float = (Sin(mPhase) + 1) / 2 * (barCount - 0.5)
	Dim pulse As Float = (Sin(mPhase * 2) + 1) / 2
	For i = 0 To barCount - 1
		Dim color As Int
		Select mState
			Case "connected"
				Dim glow As Float = 0.7 + 0.3 * pulse
				color = ShiftColor(0xFF10B981, glow)
			Case "scanning"
				Dim dist As Float = Abs(i - sweep)
				If dist < 0.8 Then
					color = 0xFFF59E0B
				Else If dist < 1.5 Then
					color = 0xFFA3A3A3
				Else
					color = 0xFFD4D4D4
				End If
			Case Else
				If i = 0 Then
					Dim b As Float = 0.5 + 0.5 * pulse
					color = ShiftColor(0xFF2563EB, b)
				Else
					color = 0xFFE5E7EB
				End If
		End Select
		mBar(i).Color = color
	Next
End Sub

Private Sub ShiftColor (Color As Int, Factor As Float) As Int
	Dim r As Int = Bit.And(Bit.ShiftRight(Color, 16), 0xFF)
	Dim g As Int = Bit.And(Bit.ShiftRight(Color, 8), 0xFF)
	Dim b As Int = Bit.And(Color, 0xFF)
	r = Min(255, r * Factor)
	g = Min(255, g * Factor)
	b = Min(255, b * Factor)
	Return Bit.Or(Bit.Or(Bit.Or(0xFF000000, Bit.ShiftLeft(r, 16)), Bit.ShiftLeft(g, 8)), b)
End Sub