// Original quiz concept inspired by Abhilash Narayan
// (https://codepen.io/abhilashn/pen/BRepQ), MIT licensed.
// Reimplemented from scratch as an htmlwidget by Saskia Otto.

HTMLWidgets.widget({

  name: 'multiQuestions',

  type: 'output',

  factory: function(el, width, height) {

    return {

      renderValue: function(x) {

        // Helper: set inline style with !important (overrides ioslides etc.)
        function setImportant(el, prop, val) {
          el.style.setProperty(prop, val, 'important');
        }

        // --------------- Get questions from R function and all other variables --------

        var quizQuestions = JSON.parse(x.questions);
        var quizType = x.choice || "single";

        // Shuffle question order if enabled (Fisher-Yates shuffle)
        if (x.shuffle === "true") {
          for (var si = quizQuestions.length - 1; si > 0; si--) {
            var sj = Math.floor(Math.random() * (si + 1));
            var temp = quizQuestions[si];
            quizQuestions[si] = quizQuestions[sj];
            quizQuestions[sj] = temp;
          }
          // Update question IDs to reflect new order
          for (var si = 0; si < quizQuestions.length; si++) {
            quizQuestions[si].id = si + 1;
          }
        }

        // Get ID from htmlwidget container
        var widgetId = document.getElementById(el.id).id;
        var widgetEl = document.getElementById(widgetId);

        // Get title
        title = x.title;

        // Get few style params
        var centerWidget = x.center;
        var scrollWidget = x.scroll;
        var inclTimer = x.inclTimer;
        var showSolutionBtn = x.showSolutionBtn;
        var fontFamily = x.fontFamily;
        var fontSize = x.fontSize;
        var titleFontSize = x.titleFontSize;
        var questionFontSize = x.questionFontSize;
        var titleCol = x.titleCol;
        var titleBg = x.titleBg;
        var questionCol = x.questionCol;
        var questionBg = x.questionBg;
        var mainCol = x.mainCol;
        var mainBg = x.mainBg;
        var optionBg = x.optionBg;
        var timerCol = x.timerCol;

        // Helper: apply styles to all elements matching a selector within this widget
        function styleAll(selector, styles) {
          var els = widgetEl.querySelectorAll(selector);
          els.forEach(function(el) {
            for (var prop in styles) {
              el.style[prop] = styles[prop];
            }
          });
        }

        // Helper: darken a hex color by a percentage (0-1)
        function darkenColor(hex, amount) {
          hex = hex.replace('#', '');
          if (hex.length === 3) hex = hex[0]+hex[0]+hex[1]+hex[1]+hex[2]+hex[2];
          var r = Math.max(0, Math.round(parseInt(hex.substring(0,2), 16) * (1 - amount)));
          var g = Math.max(0, Math.round(parseInt(hex.substring(2,4), 16) * (1 - amount)));
          var b = Math.max(0, Math.round(parseInt(hex.substring(4,6), 16) * (1 - amount)));
          return '#' + r.toString(16).padStart(2,'0') + g.toString(16).padStart(2,'0') + b.toString(16).padStart(2,'0');
        }

        // ------------ Create all HTML elements -----------------------

        var divWidget = document.getElementById(el.id);

        // Prevent click events from propagating to slide frameworks (e.g. slidy)
        divWidget.addEventListener('click', function(e) { e.stopPropagation(); });
        divWidget.addEventListener('mousedown', function(e) { e.stopPropagation(); });

        // QUIZ CONTAINER
        var divQuiz = document.createElement("div");
        divQuiz.classList.add("mqq-quiz");
        // Add user-specific CSS
        divQuiz.style.height = divWidget.style.height * 0.99;
        divQuiz.style.backgroundColor = mainBg;
        divQuiz.style.fontFamily = fontFamily;
        divQuiz.style.fontSize = fontSize+'px';
        divQuiz.style.lineHeight = fontSize*1.5+'px';

        // HEADER PART (holds the title)
        var divHeader = document.createElement("div");
        divHeader.classList.add("mqq-title");
        // Add user-specific CSS
        divHeader.style.backgroundColor = titleBg;
        divHeader.style.padding = fontSize*0.85+'px 20px';

        var divTitle = document.createElement("div");
        divTitle.classList.add("mqq-title-left");
        divTitle.innerHTML = title;
        // Add user-specific CSS
        divTitle.style.color = titleCol;
        divTitle.style.fontFamily = fontFamily;
        divTitle.style.fontSize = titleFontSize+'px';
        divTitle.style.lineHeight = titleFontSize*1.2+'px';
        if (x.titleAlign) divTitle.style.textAlign = x.titleAlign;

        var divSubtitle = document.createElement("div");
        divSubtitle.classList.add("mqq-title-right");
        divSubtitle.innerHTML = x.txtTotalQuestions + ": ";
        // Add user-specific CSS
        divSubtitle.style.color = titleCol;
        divSubtitle.style.fontFamily = fontFamily;
        divSubtitle.style.fontSize = titleFontSize+'px';
        divSubtitle.style.lineHeight = titleFontSize*1.2+'px';
        divSubtitle.style.marginRight = titleFontSize*2.2+'px';
        divSubtitle.style.flex = '0 0 '+ titleFontSize*11+'px';

        var spanTque = document.createElement("span");
        spanTque.classList.add("mqq-tque");

        var divClear= document.createElement("div");
        divClear.classList.add("mqq-clearfix");

        // Append all header elements to quiz divContainer
        divSubtitle.appendChild(spanTque);
        divHeader.appendChild(divTitle);
        divHeader.appendChild(divSubtitle);
        divHeader.appendChild(divClear);
        divQuiz.appendChild(divHeader);



        // QUESTION CONTAINER
        var divQuestion = document.createElement("div");
        divQuestion.classList.add("mqq-question");
        divQuestion.style.backgroundColor = questionBg;
        divQuestion.style.paddingTop = questionFontSize * 0.75 + 'px';
        divQuestion.style.paddingBottom = questionFontSize * 0.75 + 'px';
        divQuestion.style.paddingLeft = '20px';
        divQuestion.style.paddingRight = '20px';

        var hQuestion = document.createElement("p");
        hQuestion.classList.add("mqq-question-text");
        // Add user-specific CSS
        hQuestion.style.fontFamily = fontFamily;
        hQuestion.style.fontSize = questionFontSize+'px';
        // Flexbox layout for hanging indent (number + question text aligned)
        hQuestion.style.display = 'flex';
        hQuestion.style.alignItems = 'baseline';
        hQuestion.style.lineHeight = questionFontSize*1.25+'px';
        hQuestion.style.fontWeight = 'bold';
        hQuestion.style.color = questionCol;

        var spanQid = document.createElement("span");
        spanQid.classList.add("mqq-question-qid");
        spanQid.style.flexShrink = '0';
        spanQid.style.marginRight = '0.3em';
        var spanQuestion = document.createElement("span");
        spanQuestion.classList.add("mqq-question-span");

        // MAIN CONTAINER
        var divMain = document.createElement("div");
        divMain.classList.add("mqq-main");

        var divOption = document.createElement("div");
        divOption.classList.add("mqq-options");
        // divOption.style.marginTop = '10px';

        var divButtons =  document.createElement("div");
        divButtons.classList.add("mqq-buttons");

        var buttonPrev = document.createElement("button");
        buttonPrev.type = "button";
        buttonPrev.name = "previous";
        buttonPrev.classList.add("mqq-btn", "mqq-previous");
        buttonPrev.setAttribute('tabindex', '0');
        buttonPrev.innerHTML = x.txtPrevious;
        // Add user-specific CSS
        buttonPrev.style.fontFamily = fontFamily;
        buttonPrev.style.fontSize = fontSize+'px';
        setImportant(buttonPrev, 'color', x.navBtnCol);
        setImportant(buttonPrev, 'background-color', x.navBtnBg);
        setImportant(buttonPrev, 'background-image', 'none');
        setImportant(buttonPrev, 'border-color', x.navBtnBg);

        var buttonNext = document.createElement("button");
        buttonNext.type = "button";
        buttonNext.name = "next";
        buttonNext.classList.add("mqq-btn", "mqq-next");
        buttonNext.setAttribute('tabindex', '0');
        buttonNext.innerHTML = x.txtNext;
        // Add user-specific CSS
        buttonNext.style.fontFamily = fontFamily;
        buttonNext.style.fontSize = fontSize+'px';
        setImportant(buttonNext, 'color', x.navBtnCol);
        setImportant(buttonNext, 'background-color', x.navBtnBg);
        setImportant(buttonNext, 'background-image', 'none');
        setImportant(buttonNext, 'border-color', x.navBtnBg);

        var timer = document.createElement("input");
        timer.classList.add("mqq-timer");
        timer.type = "text";
        timer.setAttribute('tabindex', '-1');
        timer.setAttribute('aria-label', 'Timer');
        timer.readOnly = true;
        timer.value = "0:00";
        // Add user-specific CSS
        timer.style.color = timerCol;
        timer.style.fontFamily = fontFamily;
        timer.style.fontSize = fontSize+'px';
        timer.style.lineHeight = fontSize*1.25+'px';
        timer.style.width = fontSize*5+'px';


        // Append all the quiz content elements
        hQuestion.appendChild(spanQid);
        hQuestion.appendChild(spanQuestion);
        divButtons.appendChild(buttonPrev);
        divButtons.appendChild(buttonNext);

        // Create tip button (once, reused per question)
        if (x.showTipBtn === "true") {
          var tipBtn = document.createElement("button");
          tipBtn.classList.add("mqq-btn", "mqq-tip-btn");
          tipBtn.setAttribute('tabindex', '0');
          tipBtn.innerHTML = x.txtShowTips;
          tipBtn.style.fontFamily = fontFamily;
          tipBtn.style.fontSize = fontSize + 'px';
          setImportant(tipBtn, 'color', x.tipBtnCol);
          setImportant(tipBtn, 'background-color', x.tipBtnBg);
          setImportant(tipBtn, 'background-image', 'none');
          tipBtn.style.marginLeft = '15px';
          tipBtn.style.marginTop = '10px';
          tipBtn.setAttribute('aria-expanded', 'false');
          tipBtn.classList.add('mqq-hidden');
          divButtons.appendChild(tipBtn);

          tipBtn.addEventListener('click', function(e) {
            e.preventDefault();
            e.stopPropagation();
            var isExpanded = tipBtn.getAttribute('aria-expanded') === 'true';
            var tipVisible = !isExpanded;
            tipBtn.setAttribute('aria-expanded', tipVisible ? 'true' : 'false');
            var tipDiv = widgetEl.querySelector('.mqq-tip-div');
            if (tipVisible && tipBtn._tipData) {
              var td = tipBtn._tipData;
              if (td.hasTip) {
                tipDiv.innerHTML = "<p style='margin:0'>" + td.currentQ.tip + "</p>";
              } else {
                var numCorrect = Array.isArray(td.currentQ.answer) ? td.currentQ.answer.length : 1;
                tipDiv.innerHTML = "<p style='margin:0'>" + x.txtNumberOfCorrectAnswers + ": <strong>" + numCorrect + "</strong></p>";
              }
              tipDiv.style.display = 'block';
              tipBtn.innerHTML = x.txtHideTips;
            } else {
              if (tipDiv) tipDiv.style.display = 'none';
              tipBtn.innerHTML = x.txtShowTips;
            }
          });
        }

        if (inclTimer === "true") {
          divButtons.appendChild(timer);
        }

        divQuestion.appendChild(hQuestion);

        // FORM and FIELDSET wrapping the interactive content
        var divForm = document.createElement("div");
        divForm.classList.add("mqq-content");
        var formEl = document.createElement("form");
        formEl.name = "quizForm";
        var fieldset = document.createElement("fieldset");
        fieldset.classList.add("mqq-form-group");

        // Append to main container
        divMain.appendChild(divOption);
        divMain.appendChild(divButtons);

        // Tip div below buttons
        if (x.showTipBtn === "true") {
          var tipDiv = document.createElement("div");
          tipDiv.classList.add("mqq-tip-div");
          tipDiv.style.display = 'none';
          tipDiv.style.fontFamily = fontFamily;
          tipDiv.style.fontSize = fontSize + 'px';
          tipDiv.style.color = x.tipAreaCol;
          tipDiv.style.backgroundColor = x.tipAreaBg;
          tipDiv.style.border = '1px solid ' + x.tipAreaBorder;
          tipDiv.style.padding = '10px 15px';
          tipDiv.style.margin = '8px 15px 0 15px';
          tipDiv.style.borderRadius = '4px';
          divMain.appendChild(tipDiv);
        }

        // Build quiz structure: title > content > form > fieldset > (question + main)
        fieldset.appendChild(divQuestion);
        fieldset.appendChild(divMain);
        formEl.appendChild(fieldset);
        divForm.appendChild(formEl);
        divQuiz.appendChild(divForm);

        // Append final quiz to htmlwidget container
        divWidget.appendChild(divQuiz);

        // Modify parent element (the htmlwidget div)
        divWidget.style.borderRadius = "5px";
        if (centerWidget === "true") {
          divWidget.style.marginLeft = "auto";
          divWidget.style.marginRight = "auto";
        }
        if (scrollWidget === "true") {
          divWidget.style.overflowY = "auto";
          divWidget.style.overflowX = "hidden";
        }



        // --------------- Functions -------------------

        var quizApp = function() {

        	this.score = 0;
        	this.qno = 1;
        	this.currentque = 0;
        	var totalque = quizQuestions.length;

          // Function that generates the questions
        	this.displayQuiz = function(cque) {

        		this.currentque = cque;

        		if(this.currentque <  totalque) {
        			widgetEl.querySelector('.mqq-tque').innerHTML = totalque;
        			widgetEl.querySelector('.mqq-previous').disabled = false;
        			widgetEl.querySelector('.mqq-next').disabled = false;
        			widgetEl.querySelector('.mqq-question-qid').innerHTML = quizQuestions[this.currentque].id + '. ';

        			widgetEl.querySelector('.mqq-question-span').innerHTML = quizQuestions[this.currentque].question;
        			widgetEl.querySelector('.mqq-options').innerHTML = "";

              var inputType = (quizType === "multiple") ? "checkbox" : "radio";
        			for (var key in quizQuestions[this.currentque].options[0]) {
        			  if (quizQuestions[this.currentque].options[0].hasOwnProperty(key)) {
          				widgetEl.querySelector('.mqq-options').insertAdjacentHTML('beforeend',
          					"<div class='mqq-option-block' tabindex='0' role='" + (inputType === "checkbox" ? "checkbox" : "radio") + "' aria-checked='false'>" +
          					"<label class='mqq-form-check-label'>" +
          							  "<input type='" + inputType + "' class='mqq-form-check-input' name='option'   id='q"+
          							  key+"' value='"+quizQuestions[this.currentque].options[0][key]+
                          "'><span class='optionval'>" +
          								  quizQuestions[this.currentque].options[0][key] +
          							 "</span></label></div>");
        			  }
        			}
              // Add user-specific CSS (scoped to this widget)
              styleAll('.mqq-option-block', {color: mainCol, backgroundColor: optionBg});

              // Restore previous selection if exists
              if (typeof userSelections !== 'undefined' && userSelections[this.currentque] != null) {
                var saved = userSelections[this.currentque];
                if (quizType === "multiple" && Array.isArray(saved)) {
                  // MC: check all previously selected checkboxes
                  saved.forEach(function(val) {
                    var cb = widgetEl.querySelector('.mqq-options input[type=checkbox][value="' + val + '"]');
                    if (cb) {
                      cb.checked = true;
                      var block = cb.closest('.mqq-option-block');
                      if (block) block.setAttribute('aria-checked', 'true');
                    }
                  });
                } else if (typeof saved === 'string' && saved !== '') {
                  // SC: check the previously selected radio
                  var rb = widgetEl.querySelector('.mqq-options input[type=radio][value="' + saved + '"]');
                  if (rb) {
                    rb.checked = true;
                    var block = rb.closest('.mqq-option-block');
                    if (block) block.setAttribute('aria-checked', 'true');
                  }
                }
              }

              // (hover and keyboard listeners are set up once outside displayQuiz)

              styleAll('.optionval', {
                fontSize: fontSize+'px',
                lineHeight: fontSize*1.5+'px',
                marginLeft: fontSize*0.875+10+'px'
              });
              styleAll('.mqq-form-check-input', {
                width: fontSize*0.875+'px',
                height: fontSize*0.875+'px',
                marginTop: (fontSize*1.5-fontSize*0.875)/1.7+'px'
              });

              // TIP BUTTON (per question) — placed in button bar, tip div below options
              var tipBtn = widgetEl.querySelector('.mqq-tip-btn');
              var tipDiv = widgetEl.querySelector('.mqq-tip-div');

              if (x.showTipBtn === "true") {
                var currentQ = quizQuestions[this.currentque];
                var hasTip = currentQ.tip && currentQ.tip !== "";
                var isMC = quizType === "multiple";

                if (hasTip || isMC) {
                  // Show tip button and reset state
                  if (tipBtn) {
                    tipBtn.classList.remove('mqq-hidden');
                    tipBtn.innerHTML = x.txtShowTips;
                    tipBtn.setAttribute('aria-expanded', 'false');
                  }
                  if (tipDiv) {
                    tipDiv.style.display = 'none';
                    tipDiv.innerHTML = '';
                  }

                  // Store current tip data on the button for the click handler
                  if (tipBtn) {
                    tipBtn._tipData = { hasTip: hasTip, currentQ: currentQ, isMC: isMC };
                  }
                } else {
                  // No tip for this question — hide button and div
                  if (tipBtn) tipBtn.classList.add('mqq-hidden');
                  if (tipDiv) tipDiv.style.display = 'none';
                }
              }

        		  // Set focus on first option for keyboard navigation
        		  var firstOption = widgetEl.querySelector('.mqq-option-block');
        		  if (firstOption) {
        		    setTimeout(function() { firstOption.focus(); }, 50);
        		  }
        		}
        		if(this.currentque <= 0) {
        			widgetEl.querySelector('.mqq-previous').disabled = true;
        		}
        		if(this.currentque >= totalque) {
        				widgetEl.querySelector('.mqq-next').disabled = true;
        				for(var i = 0; i < totalque; i++) {
        					this.score = this.score + quizQuestions[i].score;
        				}
        			return this.showResult(this.score);
        		}
        	};


          // Function that shows the results
        	this.showResult = function(scr) {

            // First stop timer
            if (inclTimer === "true") {
              clearInterval(timeInt);
            }

            // Hide question container and tip button/div on results page
            var questionResult = widgetEl.querySelector('.mqq-question');
            if (questionResult) questionResult.style.display = 'none';
            var tipBtnResult = widgetEl.querySelector('.mqq-tip-btn');
            var tipDivResult = widgetEl.querySelector('.mqq-tip-div');
            if (tipBtnResult) tipBtnResult.classList.add('mqq-hidden');
            if (tipDivResult) tipDivResult.style.display = 'none';

            // Replace content in the quiz-body div
            var quizBody = widgetEl.querySelector('.mqq-main');
        		quizBody.classList.add('result');
        		quizBody.innerHTML = "<h3 class='mqq-res-header'>" + x.txtTotalScore + ": &nbsp;" +
            scr  + '/' + totalque + "</h3>";

        		for(var j = 0; j < totalque; j++) {
        			var res;
        			if(quizQuestions[j].score === 0) {
        					res = '<span class="mqq-wrong">' + quizQuestions[j].score;
        			} else {
        				res = '<span class="mqq-correct">' + quizQuestions[j].score;
        			}
        			var resultHTML = '<div class="mqq-result-question"><span>' + x.txtQuestion + ' ' + quizQuestions[j].id + '</span> &nbsp;' + quizQuestions[j].question + '</div>';
        			if (showSolutionBtn === "true") {
        			  // Format answer display: array for MC, string for SC
        			  var answerDisplay = Array.isArray(quizQuestions[j].answer)
        			    ? quizQuestions[j].answer.join(", ")
        			    : quizQuestions[j].answer;
        			  resultHTML += '<div class="mqq-result-answer" style="display:none;">' + x.txtCorrectAnswer + ': &nbsp;<span>' + answerDisplay + '</span></div>';
        			}
        			resultHTML += '<div class="mqq-last-row">' + x.txtScore + ': &nbsp;' + res + '</span></div>';
        			quizBody.insertAdjacentHTML('beforeend', resultHTML);
        		}

            // Add user-specific CSS (scoped to this widget)
            styleAll('.mqq-res-header', {
              color: mainCol,
              fontFamily: fontFamily,
              fontSize: fontSize*1.5+'px',
              lineHeight: fontSize*1.5+'px',
              marginBottom: fontSize*0.9375+'px',
              paddingBottom: fontSize*0.9375+'px'
            });
            styleAll('.mqq-result-question', {
              color: mainCol,
              fontSize: fontSize+'px',
              lineHeight: fontSize*1.25+'px'
            });
            styleAll('.mqq-result-answer', {
              color: x.solutionAreaCol || mainCol,
              fontSize: fontSize+'px',
              lineHeight: fontSize*1.25+'px',
              backgroundColor: x.solutionAreaBg || '#D6EAF8',
              border: '1px solid ' + (x.solutionAreaBorder || '#3498DB'),
              borderRadius: '4px',
              padding: fontSize*0.5+'px ' + fontSize*0.75+'px',
              marginTop: fontSize*0.25+'px'
            });
            styleAll('.mqq-last-row', {
              color: mainCol,
              fontSize: fontSize+'px',
              lineHeight: fontSize*1.25+'px',
              marginBottom: fontSize*0.9375+'px',
              paddingBottom: fontSize*0.9375+'px'
            });
            styleAll('.mqq-wrong', {marginLeft: fontSize*1.25+'px'});
            styleAll('.mqq-correct', {marginLeft: fontSize*1.25+'px'});


            // Button row: Try again (left) and Show solution (right)
            var buttonRow = document.createElement("div");
            buttonRow.style.display = "flex";
            buttonRow.style.flexWrap = "wrap";
            buttonRow.style.gap = "8px";
            buttonRow.style.justifyContent = "flex-start";
            buttonRow.style.alignItems = "center";
            buttonRow.style.marginTop = fontSize*0.5+'px';
            quizBody.appendChild(buttonRow);

            // Add reload button (left)
            var buttonTryagain = document.createElement("button");
            buttonTryagain.type = "button";
            buttonTryagain.name = "tryagain";
            buttonTryagain.classList.add("mqq-btn", "mqq-tryagain");
            buttonTryagain.setAttribute('tabindex', '0');
            buttonTryagain.innerHTML = x.txtTryAgain;
            buttonTryagain.style.fontFamily = fontFamily;
            buttonTryagain.style.fontSize = fontSize+'px';
            setImportant(buttonTryagain, 'color', x.navBtnCol);
            setImportant(buttonTryagain, 'background-color', x.navBtnBg);
            setImportant(buttonTryagain, 'background-image', 'none');
            setImportant(buttonTryagain, 'border-color', x.navBtnBg);
            buttonRow.appendChild(buttonTryagain);
            buttonTryagain.addEventListener('click', function() {
                location.reload(true);
            });

            // Add "Show solution" button (next to Try again, only if showSolutionBtn is true)
            if (showSolutionBtn === "true") {
              var buttonSolution = document.createElement("button");
              buttonSolution.type = "button";
              buttonSolution.name = "showsolution";
              buttonSolution.classList.add("mqq-btn", "mqq-showsolution");
              buttonSolution.setAttribute('tabindex', '0');
              buttonSolution.innerHTML = x.txtShowSolution;
              buttonSolution.style.fontFamily = fontFamily;
              buttonSolution.style.fontSize = fontSize+'px';
              setImportant(buttonSolution, 'color', x.solutionBtnCol);
              setImportant(buttonSolution, 'background-color', x.solutionBtnBg);
              setImportant(buttonSolution, 'background-image', 'none');
              buttonSolution.style.border = '1px solid ' + x.solutionBtnCol;
              buttonSolution.setAttribute('aria-expanded', 'false');
              buttonRow.appendChild(buttonSolution);
              buttonSolution.addEventListener('click', function() {
                var answerRows = widgetEl.querySelectorAll('.mqq-result-answer');
                var isVisible = answerRows[0] && answerRows[0].style.display !== 'none';
                answerRows.forEach(function(row) {
                  row.style.display = isVisible ? 'none' : '';
                });
                buttonSolution.innerHTML = isVisible ? x.txtShowSolution : x.txtHideSolution;
                buttonSolution.setAttribute('aria-expanded', isVisible ? 'false' : 'true');
              });
            }

          };


          // Function that starts the timer
          if (inclTimer === "true") {
            var timeInt;
            this.startTimer = function() {
              var tobj = widgetEl.querySelector('.mqq-timer');
              var t = "0:00";
              var s = 00;
              var d = new Date();
              timeInt = setInterval(function () {
                s += 1;
                d.setMinutes("0");
                d.setSeconds(s);
                min = d.getMinutes();
                sec = d.getSeconds();
                if (sec < 10) sec = "0" + sec;
                widgetEl.querySelector('.mqq-timer').value = min + ":" + sec;
              }, 1000);
              tobj.value = t;
            }
            if (window.addEventListener) {
              window.addEventListener("load", this.startTimer);
            } else if (window.attachEvent) {
              window.attachEvent("onload", this.startTimer);
            }
          }


          // Function that checks the answers
        	this.checkAnswer = function(option) {
        		var answer = quizQuestions[this.currentque].answer;

        		if (quizType === "multiple") {
        		  // Multiple-choice: compare sets of selected values vs answer array
        		  var selected = Array.isArray(option) ? option : [option];
        		  // Escape HTML entities in selected values
        		  selected = selected.map(function(s) {
        		    return s.replace(/</g,"&lt;").replace(/>/g,"&gt;").replace(/"/g, "&quot;");
        		  });
        		  var sortedSelected = selected.slice().sort();
        		  var sortedAnswer = answer.slice().sort();
        		  var isMatch = sortedSelected.length === sortedAnswer.length &&
        		    sortedSelected.every(function(val, idx) { return val === sortedAnswer[idx]; });
        		  if (isMatch) {
        		    if (quizQuestions[this.currentque].score == "") {
        		      quizQuestions[this.currentque].score = 1;
        		      quizQuestions[this.currentque].status = "correct";
        		    }
        		  } else {
        		    quizQuestions[this.currentque].status = "wrong";
        		  }
        		} else {
        		  // Single-choice: compare single value
        		  option = option.replace(/</g,"&lt;");
        		  option = option.replace(/>/g,"&gt;");
        		  option = option.replace(/"/g, "&quot;");

        		  if(option == quizQuestions[this.currentque].answer) {
        		  	if(quizQuestions[this.currentque].score == "") {
        		  		quizQuestions[this.currentque].score = 1;
        		  		quizQuestions[this.currentque].status = "correct";
        		    }
        		  } else {
        		  	quizQuestions[this.currentque].status = "wrong";
        		  }
        		}
        	};


          // Function that changes slides
        	this.changeQuestion = function(cque) {
        			this.currentque = this.currentque + cque;
        			this.displayQuiz(this.currentque);
        	};


        // end of quizApp wrapper function
        };


        var jsq = new quizApp();

        var selectedopt;
        // Store user selections per question (to restore when navigating back)
        var userSelections = new Array(quizQuestions.length).fill(null);

        // Display first question (no need for document.ready - htmlwidgets runs after DOM is ready)
        jsq.displayQuiz(0);

        // Hover effect via event delegation (registered ONCE)
        var optContainer = widgetEl.querySelector('.mqq-options');
        optContainer.addEventListener('mouseenter', function(e) {
          var block = e.target.closest('.mqq-option-block');
          if (block) block.style.backgroundColor = darkenColor(optionBg, 0.3);
        }, true);
        optContainer.addEventListener('mouseleave', function(e) {
          var block = e.target.closest('.mqq-option-block');
          if (block) block.style.backgroundColor = optionBg;
        }, true);

        // Keyboard: Enter/Space selects option (registered ONCE)
        optContainer.addEventListener('keydown', function(e) {
          if (e.key === 'Enter' || e.key === ' ') {
            var block = e.target.closest('.mqq-option-block');
            if (block) {
              e.preventDefault();
              var input = block.querySelector('input');
              if (input) {
                input.checked = !input.checked;
                input.dispatchEvent(new Event('change', { bubbles: true }));
                block.setAttribute('aria-checked', input.checked ? 'true' : 'false');
              }
            }
          }
        });

        // Event delegation for input changes
        widgetEl.querySelector('.mqq-options').addEventListener('change', function(e) {
          if (quizType === "multiple") {
            // Multiple-choice: collect all checked checkboxes
            if (e.target.matches('input[type=checkbox][name=option]')) {
              var checked = widgetEl.querySelectorAll('.mqq-options input[type=checkbox][name=option]:checked');
              selectedopt = [];
              checked.forEach(function(cb) { selectedopt.push(cb.value); });
            }
          } else {
            // Single-choice: single radio value
            if (e.target.matches('input[type=radio][name=option]')) {
              e.target.checked = true;
              selectedopt = e.target.value;
            }
          }
        });

      	widgetEl.querySelector('.mqq-next').addEventListener('click', function(e) {
      			e.preventDefault();
      			// Save current selection
      			userSelections[jsq.currentque] = selectedopt;
      			if(selectedopt && (Array.isArray(selectedopt) ? selectedopt.length > 0 : selectedopt !== "")) {
      				jsq.checkAnswer(selectedopt);
      			}
            // clear variable in case next question is not answered
            selectedopt = (quizType === "multiple") ? [] : "";
      			jsq.changeQuestion(1);
      			// Restore selection if user navigated back then forward again
      			if (userSelections[jsq.currentque] != null) {
      			  selectedopt = userSelections[jsq.currentque];
      			}
      	});

      	widgetEl.querySelector('.mqq-previous').addEventListener('click', function(e) {
      		e.preventDefault();
      		// Save current selection
      		userSelections[jsq.currentque] = selectedopt;
      		if(selectedopt && (Array.isArray(selectedopt) ? selectedopt.length > 0 : selectedopt !== "")) {
      			jsq.checkAnswer(selectedopt);
      		}
      			jsq.changeQuestion(-1);
      			// Restore selection for previous question
      			if (userSelections[jsq.currentque] != null) {
      			  selectedopt = userSelections[jsq.currentque];
      			} else {
      			  selectedopt = (quizType === "multiple") ? [] : "";
      			}
      	});


      // end of renderValue Function
      },

      resize: function(width, height) {

        // TODO: code to re-render the widget with a new size

      }

    };
  }
});
