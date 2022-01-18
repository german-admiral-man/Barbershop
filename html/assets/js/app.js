let beardCount = 0;
let beardCountC = 0;

let hairCount = 0;
let hairCountC = 0;

let CurrentSkin = null;

let TotalHair = 0;
let TotalHairColors = 0;
let TotalBeard = 0;
let TotalBeardColors = 0;

let firstBeard;
let firstBeardColor;
let firstHair;
let firstHairColor;

let toPay = 0;

$(function() {
    window.addEventListener('message', function(event) {
        if (event.data.type == "openUI") {
            CurrentSkin = event.data.skin;
            if (CurrentSkin.sex == 0) {
                document.getElementById('general-img').src = 'assets/images/barber-m.png';
            } else if (gender > 0) {
                document.getElementById('general-img').src = 'assets/images/barber-f.png';
            }
            if (event.data.currentBeard == 255) {
                firstBeard = -1;
            } else {
                firstBeard = event.data.currentBeard;
            }
            firstBeardColor = event.data.currentBeardColor;
            firstHair = event.data.currentHair;
            firstHairColor = event.data.currentHairColor;

            $('#container').show();
            $('#general-screen').show();
            $('#shop-container').hide();
            $('#male-box').hide();
        } else if (event.data.type == "closeUI") {
            CurrentSkin = null;
            toPay = 0;
            escape();
        } else if (event.data.type == "updateData") {
            if (event.data.totalBeards) {
                if (event.data.currentBeard == 255) {
                    beardCount = -1; 
                } else {
                    beardCount = event.data.currentBeard; 
                }
                beardCountC = event.data.currentBeardColor; 

                TotalBeard = event.data.totalBeards; 
                TotalBeardColors = event.data.beardColors; 
            }
            
            if (event.data.totalHairs) {
                hairCount = event.data.currentHair; 
                hairCountC = event.data.currentHairColor; 
                
                TotalHair = event.data.totalHairs; 
                TotalHairColors = event.data.hairColors; 
            }
            $('#beard-count').html(`${beardCount} / ${TotalBeard}`);
            $('#beard-countC').html(`${beardCountC} / ${TotalBeardColors}`);
            $('#hair-count').html(`${hairCount} / ${TotalHair}`);
            $('#hair-countC').html(`${hairCountC} / ${TotalHairColors}`);
        } else if (event.data.type == "closePayUI") {
            $('#container').hide();
        }
    });
});


$('#plusBeard').click(function (e) { 
    e.preventDefault();
    if (beardCount >= TotalBeard) return;
    beardCount++;
    $('#beard-count').html(`${beardCount} / ${TotalBeard}`);
    beardCountC = 0; 
    $('#beard-countC').html(`${beardCountC} / ${TotalBeardColors}`);  
    $.post('https://barbershop/changeDrawable', JSON.stringify({drawable: beardCount, texture: beardCountC, beard: true}));
    if (firstBeard < beardCount) {
        toPay = Config.Price;
    } else if (firstBeard == beardCount) {
        toPay = toPay - Config.Price;
    }
    $('#price').html(`${toPay}$`);
});

$('#minusBeard').click(function (e) { 
    e.preventDefault();
    if (beardCount <= -1) return beardCount = -1;
    beardCount--;
    $('#beard-count').html(`${beardCount} / ${TotalBeard}`);
    beardCountC = 0; 
    $('#beard-countC').html(`${beardCountC} / ${TotalBeardColors}`);
    $.post('https://barbershop/changeDrawable', JSON.stringify({drawable: beardCount, texture: beardCountC, beard: true}));
    if (firstBeard > beardCount) {
        toPay = Config.Price;
    } else if (firstBeard == beardCount) {
        toPay = toPay - Config.Price;
    }
    $('#price').html(`${toPay}$`);
});

$('#plusBeardC').click(function (e) { 
    e.preventDefault();
    if (beardCountC >= TotalBeardColors) return;
    beardCountC++;
    $('#beard-countC').html(`${beardCountC} / ${TotalBeardColors}`);
    $.post('https://barbershop/changeDrawable', JSON.stringify({drawable: beardCount, texture: beardCountC, beard: true}));
    if (firstBeardColor < beardCountC) {
        toPay = Config.Price;
    } else if (firstBeardColor == beardCountC) {
        toPay = toPay - Config.Price;
    }
    $('#price').html(`${toPay}$`);
});
$('#minusBeardC').click(function (e) { 
    e.preventDefault();
    if (beardCountC <= 0) return beardCountC = 0;
    beardCountC--;
    $('#beard-countC').html(`${beardCountC} / ${TotalBeardColors}`);
    $.post('https://barbershop/changeDrawable', JSON.stringify({drawable: beardCount, texture: beardCountC, beard: true}));
    if (firstBeardColor > beardCountC) {
        toPay = Config.Price;
    } else if (firstBeardColor == beardCountC) {
        toPay = toPay - Config.Price;
    }
    $('#price').html(`${toPay}$`);
});


$('#plusHair').click(function (e) { 
    e.preventDefault();
    if (hairCount >= TotalHair) return;
    hairCount++;
    $('#hair-count').html(`${hairCount} / ${TotalHair}`);
    hairCountC = 0; 
    $('#hair-countC').html(`${hairCountC} / ${TotalHairColors}`); // 
    $.post('https://barbershop/changeDrawable', JSON.stringify({drawable: hairCount, texture: hairCountC, beard: false}));
    if (firstHair < hairCount) {
        toPay = Config.Price;
    } else if (firstHair == hairCount) {
        toPay = toPay - Config.Price;
    }
    $('#price').html(`${toPay}$`);
});
$('#minusHair').click(function (e) { 
    e.preventDefault();
    if (hairCount <= -1) return hairCount = -1;
    hairCount--;
    $('#hair-count').html(`${hairCount} / ${TotalHair}`);
    hairCountC = 0; 
    $('#hair-countC').html(`${hairCountC} / ${TotalHairColors}`);
    $.post('https://barbershop/changeDrawable', JSON.stringify({drawable: hairCount, texture: hairCountC, beard: false}));
    if (firstHair > hairCount) {
        toPay = Config.Price;
    } else if (firstHair == hairCount) {
        toPay = toPay - Config.Price;
    }
    $('#price').html(`${toPay}$`);
});

$('#plusHairC').click(function (e) { 
    e.preventDefault();
    if (hairCountC >= TotalHairColors) return;
    hairCountC++;
    $('#hair-countC').html(`${hairCountC} / ${TotalHairColors}`);
    $.post('https://barbershop/changeDrawable', JSON.stringify({drawable: hairCount, texture: hairCountC, beard: false}));
    if (firstHairColor < hairCountC) {
        toPay = Config.Price;
    } else if (firstHairColor == hairCountC) {
        toPay = toPay - Config.Price;
    }
    $('#price').html(`${toPay}$`);
});
$('#minusHairC').click(function (e) { 
    e.preventDefault();
    if (hairCountC <= 0) return hairCountC = 0;
    hairCountC--;
    $('#hair-countC').html(`${hairCountC} / ${TotalHairColors}`);
    $.post('https://barbershop/changeDrawable', JSON.stringify({drawable: hairCount, texture: hairCountC, beard: false}));
    if (firstHairColor > hairCountC) {
        toPay = Config.Price;
    } else if (firstHairColor == hairCountC) {
        toPay = toPay - Config.Price;
    }
    $('#price').html(`${toPay}$`);
});

$('#paymentBtn').click(function (e) { 
    e.preventDefault();
    
    if (Number(toPay) > 0) {
        $.post('https://barbershop/goToPayment', JSON.stringify({amount: Number(toPay), hair: hairCount, hairColor: hairCountC, beard: beardCount, beardColor: beardCountC}));
    }
});

function changeData() {
    $('#general-screen').hide();
    $('#shop-container').show();
    $('#male-box').show();
}

document.onkeyup = function(data){
    if (data.which == 27){
        escape();
    }
}

function escape() {
    $('#container').hide();
    $.post('https://barbershop/escape', JSON.stringify({}));
}