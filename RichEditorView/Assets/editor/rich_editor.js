/**
 * Copyright (C) 2015 Wasabeef
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
 "use strict";

var RE = {};
var isBackwardShouldDelete = true;

window.onload = function() {
    RE.callback("ready");
};

RE.editor = document.getElementById('editor');

// Not universally supported, but seems to work in iOS 7 and 8
document.addEventListener("selectionchange", function() {
    RE.backuprange();
    RE.callback("selectionchange");

});

//looks specifically for a Range selection and not a Caret selection
RE.rangeSelectionExists = function() {
    //!! coerces a null to bool
    var sel = document.getSelection();
    if (sel && sel.type == "Range") {
        return true;
    }
    return false;
};

RE.rangeOrCaretSelectionExists = function() {
    //!! coerces a null to bool
    var sel = document.getSelection();
    if (sel && (sel.type == "Range" || sel.type == "Caret")) {
        return true;
    }
    return false;
};

RE.editor.addEventListener("input", function() {
    RE.updatePlaceholder();
    RE.backuprange();
    RE.callback("input");
});

RE.editor.addEventListener("copy", function() {
    RE.callback("copy");
});

RE.editor.addEventListener("focus", function() {
    RE.backuprange();
    RE.callback("focus");
});

RE.editor.addEventListener("blur", function() {
    RE.callback("blur");
});

RE.customAction = function(action) {
    RE.callback("action/" + action);
};

RE.updateHeight = function() {
    RE.callback("updateHeight");
}

RE.callbackQueue = [];
RE.runCallbackQueue = function() {
    if (RE.callbackQueue.length === 0) {
        return;
    }

    setTimeout(function() {
        window.location.href = "re-callback://";
    }, 0);
};

RE.getCommandQueue = function() {
    var commands = JSON.stringify(RE.callbackQueue);
    RE.callbackQueue = [];
    return commands;
};

RE.callback = function(method) {
    RE.callbackQueue.push(method);
    RE.runCallbackQueue();
};

RE.setHtml = function(contents) {
    var tempWrapper = document.createElement('div');
    tempWrapper.innerHTML = contents;
    var images = tempWrapper.querySelectorAll("img");

    for (var i = 0; i < images.length; i++) {
        images[i].onload = RE.updateHeight;
    }

    RE.editor.innerHTML = tempWrapper.innerHTML;
    RE.updatePlaceholder();
};

RE.getHtml = function() {
    return RE.editor.innerHTML;
};

RE.getText = function() {
    return RE.editor.innerText;
};

RE.getSelectedText = function() {
    return document.getSelection().toString();
};

RE.setBaseTextColor = function(color) {
    RE.editor.style.color  = color;
};

RE.setPlaceholderText = function(text) {
    RE.editor.setAttribute("placeholder", text);
};

RE.updatePlaceholder = function() {
    if (RE.editor.innerHTML.indexOf('img') !== -1 || (RE.editor.textContent.length > 0 && RE.editor.innerHTML.length > 0)) {
        RE.editor.classList.remove("placeholder");
    } else {
        if ((RE.editor.innerHTML == "") || (RE.editor.innerHTML == "<div><br></div>") || (RE.editor.innerHTML == "<br>")){
            RE.editor.text = "";
            RE.editor.classList.add("placeholder");
        }else{
            RE.editor.classList.remove("placeholder");
        }
    }
};

RE.removeFormat = function() {
    document.execCommand('removeFormat', false, null);
};

RE.setFontSize = function(size) {
    RE.editor.style.fontSize = size;
};

RE.setSelecedFontSize = function(size) {
    document.execCommand("fontSize", false, size);
};
RE.setBackgroundColor = function(color) {
    RE.editor.style.backgroundColor = color;
};

RE.setHeight = function(size) {
    RE.editor.style.height = size;
};

RE.undo = function() {
    document.execCommand('undo', false, null);
};

RE.redo = function() {
    document.execCommand('redo', false, null);
};

RE.setBold = function() {
    document.execCommand('bold', false, null);
};

RE.setItalic = function() {
    document.execCommand('italic', false, null);
};

RE.setSubscript = function() {
    document.execCommand('subscript', false, null);
};

RE.setSuperscript = function() {
    document.execCommand('superscript', false, null);
};

RE.setStrikeThrough = function() {
    document.execCommand('strikeThrough', false, null);
};

RE.setUnderline = function() {
    document.execCommand('underline', false, null);
};

RE.setTextColor = function(color) {
//    RE.restorerange();
    document.execCommand("styleWithCSS", null, true);
    document.execCommand('foreColor', false, color);
    document.execCommand("styleWithCSS", null, false);
};

RE.setTextBackgroundColor = function(color) {
    RE.restorerange();
    document.execCommand("styleWithCSS", null, true);
    document.execCommand('hiliteColor', false, color);
    document.execCommand("styleWithCSS", null, false);
};

RE.setHeading = function(heading) {
    document.execCommand('formatBlock', false, '<h' + heading + '>');
};

RE.setIndent = function() {
    document.execCommand('indent', false, null);
};

RE.setOutdent = function() {
    document.execCommand('outdent', false, null);
};

RE.setOrderedList = function() {
    document.execCommand('insertOrderedList', false, null);
};

RE.setUnorderedList = function() {
    document.execCommand('insertUnorderedList', false, null);
};

RE.setJustifyLeft = function() {
    document.execCommand('justifyLeft', false, null);
};

RE.setJustifyCenter = function() {
    document.execCommand('justifyCenter', false, null);
};

RE.setJustifyRight = function() {
    document.execCommand('justifyRight', false, null);
};

RE.getLineHeight = function() {
    return RE.editor.style.lineHeight;
};

RE.setLineHeight = function(height) {
    RE.editor.style.lineHeight = height;
};

RE.insertImage = function(url, alt) {
    var img = document.createElement('img');
    img.setAttribute("src", url);
    img.setAttribute("alt", alt);
    img.onload = RE.updateHeight;

    RE.insertHTML(img.outerHTML);
    RE.callback("input");
};

RE.setBlockquote = function() {
    document.execCommand('formatBlock', false, '<blockquote>');
};

RE.insertHTML = function(html) {
    RE.restorerange();
    document.execCommand('insertHTML', false, html);
};

RE.insertLink = function(url, title) {
    RE.restorerange();
    var sel = document.getSelection();
    if (sel.toString().length !== 0) {
        if (sel.rangeCount) {

            var el = document.createElement("a");
            el.setAttribute("href", url);
            el.setAttribute("title", title);

            var range = sel.getRangeAt(0).cloneRange();
            range.surroundContents(el);
            sel.removeAllRanges();
            sel.addRange(range);
        }
    }
    RE.callback("input");
};

RE.prepareInsert = function() {
    RE.backuprange();
};

RE.backuprange = function() {
    var selection = window.getSelection();
    if (selection.rangeCount > 0) {
        var range = selection.getRangeAt(0);
        RE.currentSelection = {
            "startContainer": range.startContainer,
            "startOffset": range.startOffset,
            "endContainer": range.endContainer,
            "endOffset": range.endOffset
        };
    }
};

RE.addRangeToSelection = function(selection, range) {
    if (selection) {
        selection.removeAllRanges();
        selection.addRange(range);
    }
};

// Programatically select a DOM element
RE.selectElementContents = function(el) {
    var range = document.createRange();
    range.selectNodeContents(el);
    var sel = window.getSelection();
    // this.createSelectionFromRange sel, range
    RE.addRangeToSelection(sel, range);
};

RE.restorerange = function() {
    var selection = window.getSelection();
    selection.removeAllRanges();
    var range = document.createRange();
    range.setStart(RE.currentSelection.startContainer, RE.currentSelection.startOffset);
    range.setEnd(RE.currentSelection.endContainer, RE.currentSelection.endOffset);
    selection.addRange(range);
};

RE.focus = function() {
    var range = document.createRange();
    range.selectNodeContents(RE.editor);
    range.collapse(false);
    var selection = window.getSelection();
    selection.removeAllRanges();
    selection.addRange(range);
    RE.editor.focus();
};

RE.focusAtPoint = function(x, y) {
    var range = document.caretRangeFromPoint(x, y) || document.createRange();
    var selection = window.getSelection();
    selection.removeAllRanges();
    selection.addRange(range);
    RE.editor.focus();
};

RE.replace = function(str) {
    getWordPrecedingCaret(RE.editor,str);
    RE.callback("input");
};
RE.blurFocus = function() {
    RE.editor.blur();
};

/**
Recursively search element ancestors to find a element nodeName e.g. A
**/
var _findNodeByNameInContainer = function(element, nodeName, rootElementId) {
    if (element.nodeName == nodeName) {
        return element;
    } else {
        if (element.id === rootElementId) {
            return null;
        }
        _findNodeByNameInContainer(element.parentElement, nodeName, rootElementId);
    }
};

var isAnchorNode = function(node) {
    return ("A" == node.nodeName);
};

RE.getAnchorTagsInNode = function(node) {
    var links = [];

    while (node.nextSibling !== null && node.nextSibling !== undefined) {
        node = node.nextSibling;
        if (isAnchorNode(node)) {
            links.push(node.getAttribute('href'));
        }
    }
    return links;
};

RE.countAnchorTagsInNode = function(node) {
    return RE.getAnchorTagsInNode(node).length;
};

/**
 * If the current selection's parent is an anchor tag, get the href.
 * @returns {string}
 */
RE.getSelectedHref = function() {
    var href, sel;
    href = '';
    sel = window.getSelection();
    if (!RE.rangeOrCaretSelectionExists()) {
        return null;
    }

    var tags = RE.getAnchorTagsInNode(sel.anchorNode);
    //if more than one link is there, return null
    if (tags.length > 1) {
        return null;
    } else if (tags.length == 1) {
        href = tags[0];
    } else {
        var node = _findNodeByNameInContainer(sel.anchorNode.parentElement, 'A', 'editor');
        href = node.href;
    }

    return href ? href : null;
};

// Returns the cursor position relative to its current position onscreen.
// Can be negative if it is above what is visible
RE.getRelativeCaretYPosition = function() {
    var y = 0;
    var sel = window.getSelection();
    if (sel.rangeCount) {
        var range = sel.getRangeAt(0);
        var needsWorkAround = (range.startOffset == 0)
        /* Removing fixes bug when node name other than 'div' */
        // && range.startContainer.nodeName.toLowerCase() == 'div');
        if (needsWorkAround) {
            y = range.startContainer.offsetTop - window.pageYOffset;
        } else {
            if (range.getClientRects) {
                var rects=range.getClientRects();
                if (rects.length > 0) {
                    y = rects[0].top;
                }
            }
        }
    }

    return y;
};
function getWordPrecedingCaret(containerEl, newVal) {
    var preceding = "",
        sel,
        range,
        precedingRange;
    if (window.getSelection) {
        sel = window.getSelection();
        if (sel.rangeCount > 0) {
            range = sel.getRangeAt(0).cloneRange();
            range.deleteContents();
            range.insertNode(document.createTextNode(newVal));
            sel.removeAllRanges();
        }
    }
}
RE.selectedPosition = function() {
    return getRectForSelectedText();
}
function getRectForSelectedText() {
    var selection = window.getSelection();
    var range = selection.getRangeAt(0);
    var rect = range.getBoundingClientRect();
    return  rect.left + "," + rect.top + "," + rect.width + "," + rect.height ;
}



RE.editor.addEventListener("click", function() {
    RE.callback("click");
//    RE.getCursrPositionValue();
});
RE.editor.addEventListener("touchend", function() {
    RE.callback("touch");
//    RE.getCursrPositionValue();
});
RE.editor.addEventListener("touchstart", function() {
    RE.callback("touch");
//    RE.getCursrPositionValue();
});

RE.editor.addEventListener("touchmove", function() {
    RE.callback("touch");
//    RE.getCursrPositionValue();
});

RE.editor.addEventListener("onmousemove", function() {
    RE.callback("touch");
//    RE.getCursrPositionValue();
});


RE.isBold = function() {
    var isAllBold = document.queryCommandState("bold");
    return isAllBold
};

RE.isItalic = function() {
    var isAllItalic = document.queryCommandState("italic");
    return isAllItalic
};

RE.isUnderline = function() {
    var isAllUnderLine = document.queryCommandState("underline");
    return isAllUnderLine
};
RE.isStrike = function() {
    var isStrikeThrough = document.queryCommandState("strikeThrough");
    return isStrikeThrough
};

RE.getColor = function() {
    var colour = document.queryCommandValue("ForeColor");
    return rgbToHex(colour)
};
RE.getFontSize = function() {
    var fontSize = document.queryCommandValue("FontSize");
    return fontSize
};

RE.getCursrPositionValue = function() {
    return getLastWord();
};

RE.replaceRhyme = function(str) {
    pasteHtmlAtCaret(RE.editor,str);
};

function rgbToHex(rgb) {
   var a = rgb.split("(")[1].split(")")[0];
    a = a.split(",");
    var b = a.map(function(x){
        x = parseInt(x).toString(16);
        return (x.length==1) ? "0"+x : x;
    });
    b = b.join("");
    return b;
}

function getLastWord(){
    var selection = window.getSelection();
    if (selection.rangeCount > 0) {
        var range = selection.getRangeAt(0);
        var text = range.startContainer.data;
        var index = range.endOffset;
        if(text && text.replace(/^\s+|\s+$/g, "") !== ""){
        }else{
            isBackwardShouldDelete = true;
            if ((typeof text == "undefined") || (text.replace(/^\s+|\s+$/g, "") == "")){
                isBackwardShouldDelete = true;
                if(getTextUntilCursor() != ""){
                    var tempStr = getTextUntilCursor().trim().split(' ');
                    return tempStr[tempStr.length - 1];
                }
                return "\n";
            }
            return "";
        }
        if(RE.editor.contentEditable == "true"){
            if (index > 0 && (text[index - 1] == ' ' || text.charCodeAt(index - 1) == 160)) {
                // Click after a space
                if(index == text.length){
                    if(range.startContainer.nextSibling){
                        if(range.startContainer.nextSibling.innerText){
                            var nextSibling = range.startContainer.nextSibling.innerText
                            isBackwardShouldDelete = false;
                            return nextSibling.trim().split(" ")[0];
                        }else if (range.startContainer.nextSibling.data){
                            var nextSiblingData = (range.startContainer.nextSibling.data).replace(/^\s+|\s+$/g, "");
                            if (nextSiblingData == ""){
                                if(range.startContainer.previousSibling){
                                    if(range.startContainer.previousSibling.innerText){
                                        var previousSibling = range.startContainer.previousSibling.innerText
                                        isBackwardShouldDelete = false;
                                        return previousSibling.trim().split(" ")[0];
                                    }else if (range.startContainer.previousSibling.data){
                                        var previousSibling = range.startContainer.previousSibling.data
                                        isBackwardShouldDelete = true;
                                        return previousSibling.trim().split(" ")[0];
                                    }
                                }
                            }else{
                                var nextSibling = range.startContainer.nextSibling.data
                                isBackwardShouldDelete = false;
                                return nextSibling.trim().split(" ")[0];
                            }
                        }
                    }
                }
                var text = range.startContainer.data;
                var prefixString = text.substring(0,index)
                var shortString = prefixString.replace(/^\s+|\s+$/g, "");
                var shortString2 = text.substring(index,text.length);
                var lastword = ""
                if(shortString == ""){
                    lastword = shortString2.trim().split(" ")[0]
                    isBackwardShouldDelete = false;
                    return lastword;
                }else{
                    lastword = shortString.substring(shortString.lastIndexOf(" ", shortString.lanth -1),shortString.length);
                }
                if (((prefixString[prefixString.length-1] === " ") || (prefixString[prefixString.length-1] === " ")) && (typeof shortString2[0] !== "undefined") && !((shortString2[0] === " ") || (shortString2[0] === " "))){
                    let tempString = shortString2.replace(/^\s+|\s+$/g, "");
                    isBackwardShouldDelete = false;
                    if (tempString.length == 0){
                        return lastword;
                    }
                    return tempString.split(" ")[0];
                }
                isBackwardShouldDelete = true;
                return lastword;
            }else {
                if (typeof text == "undefined"){
                    isBackwardShouldDelete = true;
                    if(getTextUntilCursor() != ""){
                        var tempStr = getTextUntilCursor().trim().split(' ');
                        return tempStr[tempStr.length - 1];
                    }
                    return "\n";
                }
                var text = range.startContainer.data;
                var shortString = text.substring(0,index);
                var shortString2 = text.substring(index,text.length);
                var lastword = shortString.substring(shortString.lastIndexOf(" ", shortString.lanth -1),shortString.length);
                var addWord = "";
                if (shortString2[0] !== " " && shortString2[0]  !== "undefined"){
                   let tempString = shortString2.replace(/^\s+|\s+$/g, "");
                   addWord = tempString.split(" ")[0];
                }
                isBackwardShouldDelete = true;
                return lastword + addWord;
            }
        }else{
            isBackwardShouldDelete = true;
            return "";
        }
    }else{
        isBackwardShouldDelete = true;
        return "";
    }
}

function pasteHtmlAtCaret(e,newHtml) {
    if (RE.getSelectedText() == "" || RE.getSelectedText() == "undefined"){
        var elt = e;
        var sel;
        var tempText = newHtml;
        var spaceCount = 0;
        var newLinesCount = 0;
        var cursorWord = getLastWord().trim();
        if (elt.isContentEditable) {  // for contenteditable
            sel = document.getSelection();
            sel.modify("extend", "forward", "word");
            var range = sel.getRangeAt(0);
            let firstChar = sel.toString()[0];
            var isBackwardDelete = true;
            if (firstChar){
                if (firstChar !== " "){
                    if (firstChar !== " ") {
                        if(firstChar !== "\n"){
                            var lastIndexWord = "";
                            if (cursorWord.length > 0){
                                lastIndexWord = cursorWord.split(' ');
                                if(lastIndexWord == sel.toString()){
                                    isBackwardDelete = false;
                                }
                            }
//                            if(sel.toString()[sel.toString().length-1]){
//                                if ((sel.toString()[sel.toString().length-1] == 'undefined') || (sel.toString()[sel.toString().length-1] == '\n')){
//                                    sel.modify("extend", "backward", "character");
//                                    sel.modify("extend", "backward", "character");
//                                    var stttttt11 = "1pasteHtmlAtCaretCallBack:!!E Last word was new line " + sel.toString() + (sel.toString()[sel.toString().length-1]);
//                                    RE.callback(stttttt11);
//                                }
//                            }else{
//                                var stttttt11 = "1pasteHtmlAtCaretCallBack:!!E Last word was new line undefined" + sel.toString() + (sel.toString()[sel.toString().length-1]);
//                                RE.callback(stttttt11);
//                            }

//                            if((sel.toString().charAt(sel.toString()-1)) == "\n"){
//                                var stttttt1 = "1pasteHtmlAtCaretCallBack:!!E Last word was new line " + ;
//                                RE.callback(stttttt1);
//                            }
//                            sel.modify("extend", "backward", "character");
                            
//                            var stttttt1 = "1pasteHtmlAtCaretCallBack:!!E Last and selected word" + ":" + cursorWord + ":" + sel.toString() + ":" + lastIndexWord;
//                            RE.callback(stttttt1);
                            if (firstChar.trim() === ""){
                                isBackwardDelete = false;
//                                var stttttt = "1pasteHtmlAtCaretCallBack:A isBackwardDelete false" + sel.toString() + spaceCount.toString();
//                                RE.callback(stttttt);
                            }
                            spaceCount = spaceCount + sel.toString().split(' ').length +  sel.toString().split(' ').length - 2
                            newLinesCount = newLinesCount + sel.toString().split('\n').length - 1;
//                            var stttttt = "1pasteHtmlAtCaretCallBack:B isBackwardDelete true" + sel.toString() + spaceCount.toString() + newLinesCount.toString();
//                            RE.callback(stttttt);
                            range.deleteContents();

                        }
                    }
                }
            }
            range.collapse(true);
            if((isBackwardDelete == true) && (isBackwardShouldDelete == true)){
                var sel1;
                var i = 0, n =0;
                var isbOOlTemp = true;
                while(isbOOlTemp){
                    sel1 = document.getSelection();
                    var endNode = sel1.focusNode, endOffset = sel1.focusOffset;
                    var isLoopEntered = false;
                    for (i = 0; i < n; i++) {
                        sel1.modify("move", "backward", "word");
                        isLoopEntered = true;
                    }
                    sel1.modify("extend", "backward", "word");
                    sel1.extend(endNode, endOffset)
                    if (isLoopEntered == true){
                        if (sel1.toString() == ""){
                            isbOOlTemp = false;
                            tempText = newHtml + " ";
                        }
                    }
                    var selRange = sel1.toString();
                    if (selRange){
                        if (selRange.trim() !== ""){
                            isbOOlTemp = false
                        }else{
                            n = n+1;
                        }
                    }else{
                        n = n+1;
                    }
                }
                var range1 = sel1.getRangeAt(0);
                spaceCount = spaceCount + sel1.toString().split(' ').length +  sel1.toString().split(' ').length - 2
                newLinesCount = newLinesCount + sel1.toString().split('\n').length - 1;
//                var stttttt = "1pasteHtmlAtCaretCallBack:C isBackwardDelete true" + sel1.toString() + spaceCount.toString() + newLinesCount.toString();
//                RE.callback(stttttt);
                range1.deleteContents();
                range1.collapse(true);
            }
            var el = document.createElement("div");
            el.innerHTML = newHtml;
            var frag = document.createDocumentFragment(), node,lastNode;
            while (node = el.firstChild) {
                lastNode = frag.appendChild(node);
            }
            range.insertNode(frag);
            if (lastNode) {
                range = range.cloneRange();
                range.setStartAfter(lastNode);
                range.collapse(true);
                sel.removeAllRanges();
                sel.addRange(range);
            }
            if(spaceCount > 0 || newLinesCount > 1){
                var j = 0,k = 1;
                var tempStr = "";
                for(j=0;j<spaceCount;j++){
                    tempStr = tempStr + " ";
                }
                for(k=1;k<newLinesCount;k++){
                    tempStr = tempStr + "</br>";
                }
                var el1 = document.createElement("div");
                el1.innerHTML = tempStr;
                var frag1 = document.createDocumentFragment(), node1,lastNode1;
                while (node1 = el1.firstChild) {
                    lastNode1 = frag1.appendChild(node1);
                }
                range.insertNode(frag1);
                if (lastNode1) {
                    range = range.cloneRange();
                    range.setStartAfter(lastNode1);
                    range.collapse(true);
                }
                range.collapse();
            }
        }
    }else{
        var sel, range;
        if (window.getSelection) {
            sel = window.getSelection();
            if (sel.getRangeAt && sel.rangeCount) {
                range = sel.getRangeAt(0);
                range.deleteContents();
                var el = document.createElement("div");
                el.innerHTML = newHtml;
                var frag = document.createDocumentFragment(), node, lastNode;
                while ( (node = el.firstChild) ) {
                    lastNode = frag.appendChild(node);
                }
                range.insertNode(frag);
                
                // Preserve the selection
                if (lastNode) {
                    range = range.cloneRange();
                    range.setStartAfter(lastNode);
                    range.collapse(true);
                    sel.removeAllRanges();
                    sel.addRange(range);
                }
            }
        } else if (document.selection && document.selection.type != "Control") {
            document.selection.createRange().pasteHTML(html);
        }
    }
}

function getTextUntilCursor() {
    var str = 0;
    var range = window.getSelection().getRangeAt(0);
    var preCaretRange = range.cloneRange();
    preCaretRange.selectNodeContents(RE.editor);
    preCaretRange.setEnd(range.endContainer, range.endOffset);
    str = preCaretRange.toString();
    return str;
}
