// Reception // 
var BusinessMoney = 0;
var MotelName = "KibraMotel";
var MotelId = 0;
var MotelRooms = 0;
// Boss Menu // 
var MotelUid = 0

$(function() {
    window.addEventListener('message', function(event) {
        if (event.data.type === "OpenMotel"){
            $('#Container').fadeIn(500);
            MotelRooms = event.data.pMotels
            MotelName = event.data.Motel.MotelName
            MotelId = event.data.id
            BusinessMoney = event.data.Motel.SalePrice;
            $('#mtlname').html(MotelName)
            $('#MotelRoomSayi').html(event.data.mRooms);
            var oText = ""
            if (MotelRooms === false){
                oText = oText + `
                <center><button class="ButtonGroupElement" type="button">All Rooms</button></center>
                `
            }else {
                oText = oText + `
               <center><button class="ButtonGroupElement" id="AllMotelRooms" type="button">All Rooms</button>
                <button id="MyMotelRooms" class="ButtonGroupElement" type="button">My Motel Rooms</button></center>
                `
            }
            $('.ButtonGroup').html(oText)
            var htmlYazi = ""
            for (let data = 0; data < event.data.Motel.Rooms.length; data++) {
                const element = event.data.Motel.Rooms[data];
                var odaid = data+1
                if (element.Owner === "") {
                    htmlYazi = htmlYazi + `
                    <div class="Room">
                        <h1>Room ${odaid}</h1>
                        <button id="RentMotelRoom" data-mid="${event.data.id}" data-roomid="${data+1}" class="RentButton">($${event.data.Motel.RoomRentPrice}) Rent Room</button>
                    </div>
                ` 
                }
            };
            let cText = "";
            if(event.data.Motel.Owner === ""){
                cText = cText + `<h1 class="BuyMotelText">Want to buy this <b>Motel</b> business? <button id="MotelSatinAl" class="MotelBuyButton">Buy</button></h1>`
            } else if(event.data.Motel.Owner === event.data.pCid){
                cText = cText + `<center><button id="MotelBossOpen" class="MotelBuyButtonX"><i class="fa-solid fa-gears"></i> Boss Menu (${MotelName})</button></center>`
            }
            $('#MotelText').html(cText);
            $('.MotelRoomsTable').html(htmlYazi);
        } else if (event.data.type === "CloseMotel"){
            $('#Container').fadeOut(500)
            $.post('http://kibra-motelsv2/CloseMotel', JSON.stringify({}));
        } else if(event.data.type === "MotelDataLoad"){
            var yText = ""
            for (let data = 0; data < event.data.Motel.Rooms.length; data++) {
                const element = event.data.Motel.Rooms[data];
                var odaid = data+1
                if (element.Owner === "") {
                    yText = yText + `
                    <div class="Room">
                        <h1>Room ${odaid}</h1>
                        <button id="RentMotelRoom" data-roomid="${data+1}" class="RentButton">($50) Rent Room</button>
                    </div>
                ` 
                }
            };
            $('.MotelRoomsTable').html("");
            $('.MotelRoomsTable').html(yText);
        } else if (event.data.type === "CloseModal"){
            $("body").css("background-color","transparent");
            $('#MotelBuyTemplate').html("")
        } else if(event.data.type == "BossMenuOpen"){
            var bMotels = event.data.bMotels
            MotelUid = event.data.mid
            $('#BossMenuContainer').fadeIn(500);
            $('#SellMoney').html(event.data.sellmoney);
            $('#ModelName').html(bMotels.MotelName);
            $('#MotelNameX').html(bMotels.MotelName);
            $('#BossMenuMoney').html("$"+bMotels.SocietyMoney);
            $('#RentMoney').html("$"+bMotels.RoomRentPrice);
            var hText = ""
            for (let data = 0; data < bMotels.Rooms.length; data++) {
                const element = bMotels.Rooms[data];
                if (element.Owner !== "") {
                    hText = hText + `
                    <div class="Oda">
                        <div class="LeftPart">
                            <div class="RoomId"><h1>#${data+1}</h1></div>
                            <div style="width:22vh;"id="Owner" class="RoomId"><h2><font style="font-weight: 400">${element.pData.pName}</font></h2></div>
                            <div style="width:18vh;"id="Owner" class="RoomId"><h2><font style="font-weight: 400"><i class="fa-solid fa-phone"></i> ${element.pData.pPhone}</font></h2></div>
                            <div style="width:14vh;"id="Owner" class="RoomId"><h2><font style="font-weight: 400">${element.Date}</font></h2></div>
                        </div>
                        <div class="RightPart">
                            <button id="PlayerMotelKickRoom" rid="${data+1}" class="BossIslemBut" type="button">Kick</button>
                        </div>
                    </div>
                    ` 
                } else {
                    hText = hText + `
                    <div class="Oda">
                        <div class="LeftPart2">
                            <div class="RoomId"><h1>#${data+1}</h1></div>
                            <div style="width:107vh;"id="Owner" class="RoomId"><h3><font style="font-weight: 400">EMPTY ROOM</font></h3></div>
                        </div>
                    </div>
                    ` 
                }
                 $('.MTable').html(hText)

            };
        } else if (event.data.type === "ReloadMyMotelRooms"){
            var yText = "";
            for (let data = 0; data < event.data.data.length; data++) {
                const element = event.data.data[data];
                var odaid = data+1
                yText = yText + `
                <div class="RoomBig">
                    <h1>Room ${element.roomid}</h1>
                    <button motel="${element.roomid}" id="LeaveMotelRoom" class="RentButton2">Leave the Room</button>
                    <button motel="${element.roomid}" id="NewMotelKey" class="RentButton2">Copy Room Key</button>
                    <button motel="${element.roomid}" id="CopyMotelKey" class="RentButton2">Change Room Key</button>
                </div>`
            };
            $('.MotelRoomsTable').html("");
            $('.MotelRoomsTable').html(yText)
        } else if (event.data.type === "BossMenuClose"){
            $('#BossMenuContainer').fadeOut(500);
            BusinessMoney = 0;
            $.post('http://kibra-motelsv2/CloseMotel', JSON.stringify({}));        }
    });
});

document.onkeyup = function(data){
    if (data.which == 27){
        $("body").css("background-color","transparent");
        $('#MotelBuyTemplate').html("")
        $('#Container').fadeOut(500);
        $('#BossMenuContainer').fadeOut(500);
        BusinessMoney = 0;
        $.post('http://kibra-motelsv2/CloseMotel', JSON.stringify({}));
    }
}

$(document).on('click','#XloseMotel',function(){
    $("body").css("background-color","transparent");
    $('#MotelBuyTemplate').html("")
    $('#Container').fadeOut(500);
    $.post('http://kibra-motelsv2/CloseMotel', JSON.stringify({}));
})

$(document).on('click','#Deposit',function(){
    $.post('http://kibra-motelsv2/DepositMoney', JSON.stringify({
        Money: $('#MoneyMiktar').val(),
        MotelId: MotelUid
    }));
})

$(document).on('click','#PlayerMotelKickRoom' ,function(){
    Mid = $(this).attr("rid")
    $.post('http://kibra-motelsv2/xTargetKickMotel', JSON.stringify({
        RoomId: Mid,
        MotelId: MotelUid
    }));
})

$(document).on('click','#TransferMotelOwnership',function(){
    $.post('http://kibra-motelsv2/TransferMotelOwnership', JSON.stringify({
        MotelId: MotelUid
    }));
})

$(document).on('click','#RenameMotel',function(){
    $.post('http://kibra-motelsv2/RenameMotel', JSON.stringify({
        mName: $('#NewMotelName').val(),
        MotelId: MotelUid
    }));
})

$(document).on('click','#ChangeRoomRentPrice',function(){
    $.post('http://kibra-motelsv2/ChangeRoomRentPrice', JSON.stringify({
        mRoomPrice: $('#ibel').val(),
        MotelId: MotelUid
    }));
})

$(document).on('click','#Withdraw',function(){
    $.post('http://kibra-motelsv2/WithdrawMoney', JSON.stringify({
        Money: $('#MoneyMiktar').val(),
        MotelId: MotelUid
    }));
})

$(document).on('click','#SellMotel',function(){
    $.post('http://kibra-motelsv2/SellMotel', JSON.stringify({
        MotelId: MotelUid
    })); 
})


$(document).on('click','#Guvercin',function(){
    $("body").css("background-color","transparent");
        $('#MotelBuyTemplate').html("")
        $('#Container').fadeOut(500);
        $('#BossMenuContainer').fadeOut(500);
        BusinessMoney = 0;
    $.post('http://kibra-motelsv2/CloseMotel', JSON.stringify({}));
})

$(document).on('click','#MotelBossOpen',function(){
    $("body").css("background-color","transparent");
    $('#MotelBuyTemplate').html("")
    $('#Container').hide()
    $.post('http://kibra-motelsv2/OpenBossMenu', JSON.stringify({}));
})

$(document).on("click", "#MyMotelRooms", function(){
    $.post('http://kibra-motelsv2/MyMotelRooms', JSON.stringify({}));
})

$(document).on("click", "#AllMotelRooms", function(){
    $.post('http://kibra-motelsv2/LoadAllRooms', JSON.stringify({}));
})

$(document).on("click", "#LeaveMotelRoom", function(){
    Mid = $(this).attr("motel")
    $.post('http://kibra-motelsv2/LeaveMotelRoom', JSON.stringify({
        mid: Mid
    }));
})

$(document).on("click", "#CopyMotelKey", function(){
    Mid = $(this).attr("motel")
    $.post('http://kibra-motelsv2/CopyMotelKey', JSON.stringify({
        mid: Mid
    }));
})

$(document).on("click", "#NewMotelKey", function(){
    Mid = $(this).attr("motel")
    $.post('http://kibra-motelsv2/NewMotelKey', JSON.stringify({
        mid: Mid
    }));
})


$(document).on('click','#MotelSatinAl',function(){
    $("body").css("background-color","rgba(0,0,0,0.6)");
    var hText = "";
    hText = hText + `
    <div class="BuyMotelTemplate">
        <div class="BuMotelTempHeader">
            <h1>Buy This Business <button id="CloseModal" class="CloseButton2"><i class="fa-solid fa-xmark"></i></button></h1>
        </div>
        <h1 class="BuyMotelTextClass">Would you like to buy this business for <b>$${BusinessMoney}</b></h1>
        <button id="MotelBuy" motelid="${MotelId}" class="BuyMotelBigButton">Buy ${MotelName}</button>
    </div> `
    $('#MotelBuyTemplate').html(hText)
})


$(document).on('click','#CloseModal',function(){
    $("body").css("background-color","transparent");
    $('#MotelBuyTemplate').html("")
})

$(document).on('click','#MotelBuy',function(e){
    e.preventDefault();
    Mid = $(this).attr("motelid")
    $.post('http://kibra-motelsv2/BuyMotel', JSON.stringify({
        mid: Mid,
    })); 
})

$(document).on('click','#RentMotelRoom',function(e){
    e.preventDefault();
    Rid = $(this).attr("data-roomid")
    Mid = $(this).attr("data-mid")
    $.post('http://kibra-motelsv2/BuyMotelRoom', JSON.stringify({
        rid: Rid,
        mid: Mid
    })); 
})