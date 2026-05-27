// Original quiz concept inspired by Ozzie Kirkby
// (https://codepen.io/ozzie/pen/pvrVLm), MIT licensed.
// Reimplemented from scratch as an htmlwidget by Saskia Otto.

HTMLWidgets.widget({

  name: 'singleQuestion',

  type: 'output',

  factory: function(el, width, height) {

    return {

      renderValue: function(x) {

        // Helper: set inline style with !important (overrides ioslides etc.)
        function setImportant(el, prop, val) {
          el.style.setProperty(prop, val, 'important');
        }

        // --------------- Get questions from R function and all other variables --------

        var myQuestion = JSON.parse(x.question);

        // Shuffle options if enabled (Fisher-Yates shuffle)
        if (x.shuffle === "true") {
          var options = myQuestion[1].slice(); // copy options array
          var answer = myQuestion[2]; // correct answer (text or array of texts)
          for (var si = options.length - 1; si > 0; si--) {
            var sj = Math.floor(Math.random() * (si + 1));
            var temp = options[si];
            options[si] = options[sj];
            options[sj] = temp;
          }
          myQuestion[1] = options;
          // answer is stored as text, so it stays correct regardless of order
        }

        var nOpt = myQuestion[1].length;

        // Get ID frim htmlwidget container
        var widgetId = document.getElementById(el.id).id;

        // Get title
        title = x.title;

        // Get few style params
        var centerWidget = x.center;
        var scrollWidget = x.scroll;
        var fontFamily = x.fontFamily;
        var fontSize = x.fontSize;
        var titleCol = x.titleCol;
        var titleBg = x.titleBg;
        var titleFontSize = x.titleFontSize;
        var questionCol = x.questionCol;
        var questionBg = x.questionBg;
        var mainCol = x.mainCol;
        var mainBg = x.mainBg;
        var optionBg = x.optionBg;
        var optionLabelBg = x.optionLabelBg;

        // Helper: darken a hex color by a percentage (0-1)
        function darkenColor(hex, amount) {
          hex = hex.replace('#', '');
          if (hex.length === 3) hex = hex[0]+hex[0]+hex[1]+hex[1]+hex[2]+hex[2];
          var r = Math.max(0, Math.floor(parseInt(hex.substring(0,2), 16) * (1 - amount)));
          var g = Math.max(0, Math.floor(parseInt(hex.substring(2,4), 16) * (1 - amount)));
          var b = Math.max(0, Math.floor(parseInt(hex.substring(4,6), 16) * (1 - amount)));
          return '#' + r.toString(16).padStart(2,'0') + g.toString(16).padStart(2,'0') + b.toString(16).padStart(2,'0');
        }
        var optionLabelHoverBg = darkenColor(optionLabelBg, 0.3);

        // Create vars
        var lettCap = ["A","B","C","D","E","F","G","H","I","J","K",
        	"L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"];
        var lett = [];
        for (let i = 0; i < lettCap.length; i++) {
        	lett[i] = lettCap[i].toLowerCase();
        }

        // ------------ Create all HTML elements -----------------------

        var divWidget = document.getElementById(el.id);

        // Prevent click events from propagating to slide frameworks (e.g. slidy)
        divWidget.addEventListener('click', function(e) { e.stopPropagation(); });
        divWidget.addEventListener('mousedown', function(e) { e.stopPropagation(); });

        // QUIZ CONTAINER
        var divQuiz = document.createElement("div");
        divQuiz.classList.add("sqq-quiz");
        divQuiz.style.backgroundColor = mainBg;
        if (scrollWidget === "true") {
          divWidget.style.overflowY = "auto";
          divWidget.style.overflowX = "hidden";
        }


        // TITLE (as header div, similar to fillBlanks)
        var qTitle = title;
        if (qTitle !== "NULL") {
          var divHeader = document.createElement("div");
          divHeader.classList.add("sqq-title");
          divHeader.style.backgroundColor = titleBg;
          divHeader.style.padding = fontSize*0.75+'px 20px';

          var pTitle = document.createElement("p");
          pTitle.classList.add("sqq-title-text");
          pTitle.innerHTML = qTitle;
          pTitle.style.color = titleCol;
          pTitle.style.fontFamily = fontFamily;
          pTitle.style.fontSize = titleFontSize+'px';
          pTitle.style.fontWeight = 'bold';
          pTitle.style.margin = '0';
          pTitle.style.textAlign = x.titleAlign || 'left';

          divHeader.appendChild(pTitle);
          divQuiz.appendChild(divHeader);
        }

        // QUESTION CONTAINER
        var divQuestion = document.createElement("div");
        divQuestion.classList.add("sqq-question");
        divQuestion.style.backgroundColor = questionBg;


        // Actual question text
        var pQuestion = document.createElement("p");
        pQuestion.classList.add("sqq-question-text");
        pQuestion.innerHTML = myQuestion[0];
        // Add user-specific CSS
        var questionFontSize = x.questionFontSize || fontSize;
        pQuestion.style.color = questionCol;
        pQuestion.style.fontFamily = fontFamily;
        pQuestion.style.fontSize = questionFontSize+'px';
        pQuestion.style.lineHeight = questionFontSize*1.25+'px';
        pQuestion.style.padding = questionFontSize*0.6+ 'px 20px';


        // Append above HTML elements to quiz container
        divQuestion.appendChild(pQuestion);
        divQuiz.appendChild(divQuestion);


				// MAIN CONTAINER
        var optionContainer = document.createElement("div");
        optionContainer.classList.add("sqq-main");

        // OPTIONS WRAPPER
        var optionsWrapper = document.createElement("div");
        optionsWrapper.classList.add("sqq-options");
        optionContainer.appendChild(optionsWrapper);

        // Each question in an individual row.option element
        for (let i = 0; i < nOpt; i++) {

          let rowOption = document.createElement("div");
          rowOption.classList.add("sqq-option-row");
          rowOption.id = `sqq-row-${lett[i]}`;
          rowOption.setAttribute('tabindex', '0');
          rowOption.setAttribute('aria-label', 'Option ' + lettCap[i] + ': ' + myQuestion[1][i]);
          if (x.choice === 'multiple') {
            rowOption.setAttribute('role', 'checkbox');
            rowOption.setAttribute('aria-checked', 'false');
          } else {
            rowOption.setAttribute('role', 'button');
          }
          // add user-specific CSS
          rowOption.style.minHeight = fontSize*2+'px';
          rowOption.style.backgroundColor = optionBg;
          rowOption.style.color = mainCol;

					// Create 2 columns inside row
					let colOption1 = document.createElement("div");
					colOption1.classList.add("sqq-option-cols", "sqq-option-col1");
          colOption1.style.width = 40+fontSize*1.25+'px';
          colOption1.style.flex = '0 0 '+ (30+fontSize*3)+'px';

					let colOption2 = document.createElement("div");
					colOption2.classList.add("sqq-option-cols", "sqq-option-col2", "sqq-clearfix");

          let divLett = document.createElement("div");
          divLett.classList.add("sqq-div-letter");
          // add user-specific CSS
          divLett.style.height = fontSize*1.1*2+'px';
          divLett.style.width =  fontSize*1.1*2*1.1+'px';
          divLett.style.backgroundColor = optionLabelBg;

          let pLett = document.createElement("p");
          pLett.classList.add("sqq-p-lett");
          pLett.innerHTML = lettCap[i];
          // add user-specific CSS
          pLett.style.fontFamily = fontFamily;
          pLett.style.fontSize = fontSize*1.1+'px';
          pLett.style.lineHeight = fontSize*1.1+'px';
          pLett.style.paddingTop = fontSize*1.1/2+'px';
          pLett.style.paddingBottom = fontSize*1.1/2+'px';

					let divText = document.createElement("div");
					divText.classList.add("sqq-div-text");

          let pText = document.createElement("p");
          pText.classList.add("sqq-p-text");
          pText.innerHTML = myQuestion[1][i];
          pText.style.fontFamily = fontFamily;
          pText.style.fontSize = fontSize+'px';
          pText.style.lineHeight = fontSize*1.25+'px';
          pText.style.paddingTop = fontSize*1+ 'px';
          pText.style.paddingBottom = fontSize*1+ 'px';
          pText.style.paddingLeft = '0';
          pText.style.paddingRight = '20px';

          // Now append all the HTML elements belonging to each option
          divLett.appendChild(pLett);
          colOption1.appendChild(divLett);
          divText.appendChild(pText);
          colOption2.appendChild(divText);

          rowOption.appendChild(colOption1);
          rowOption.appendChild(colOption2);
          // in each iteration append row
          optionsWrapper.appendChild(rowOption);

        }

        // Now append all option container to quiz container
        divQuiz.appendChild(optionContainer);
        // Append final quiz to htmlwidget container
        divWidget.appendChild(divQuiz);


        // Modify parent element (the htmlwidget div)
        divWidget.style.borderRadius = "5px";
        if (centerWidget === "true") {
          divWidget.style.marginLeft = "auto";
          divWidget.style.marginRight = "auto";
        }


        // --------------- Functions -------------------

        var quizType = x.choice || "single";

        // Function to animate mouse hovering over options
        function letterHover(row) {
          var letterEl = row.querySelector('.sqq-div-letter');
          row.addEventListener('mouseenter', function() {
            letterEl.style.backgroundColor = optionLabelHoverBg;
          });
          row.addEventListener('mouseleave', function() {
            // If selected (MC mode), keep the darker color
            if (row.classList.contains('sqq-selected')) {
              letterEl.style.backgroundColor = optionLabelHoverBg;
            } else {
              letterEl.style.backgroundColor = optionLabelBg;
            }
          });
        }

        // Apply letterHover and keyboard support to each answer option
        for (let i = 0; i < nOpt; i++) {
          var rowEl = document.querySelector(`#${widgetId} #sqq-row-${lett[i]}`);
          if (rowEl) {
            letterHover(rowEl);
            // Keyboard: Enter or Space triggers click
            rowEl.addEventListener('keydown', function(e) {
              if (e.key === 'Enter' || e.key === ' ') {
                e.preventDefault();
                this.click();
              }
            });
          }
        }

        // Functions for the color changing as feedback
        function isCorrect() {
          document.querySelector(`#${widgetId} .sqq-question`).style.backgroundColor = "#46a346";
          document.querySelector(`#${widgetId} .sqq-question-text`).style.color = "white";
        }

        function isWrong() {
          document.querySelector(`#${widgetId} .sqq-question`).style.backgroundColor = "#CB382F";
          document.querySelector(`#${widgetId} .sqq-question-text`).style.color = "white";
        }


        if (quizType === "single") {
          // SINGLE-CHOICE MODE: click immediately shows correct/wrong

          function answer(row, bool) {
            if (bool === true) {
              row.addEventListener('click', function() {
                isCorrect();
              });
            } else if (bool === false) {
              row.addEventListener('click', function() {
                isWrong();
              });
            }
          }

          for (let j = 0; j < nOpt; j++) {
            let corrAns = myQuestion[1][j] === myQuestion[2];
            var rowElSC = document.querySelector(`#${widgetId} #sqq-row-${lett[j]}`);
            if (rowElSC) answer(rowElSC, corrAns);
          }

          // SC MODE: TIP AND SOLUTION BUTTONS
          var scShowTipBtn = x.showTipBtn;
          var scShowSolutionBtn = x.showSolutionBtn;

          if (scShowTipBtn === "true" || scShowSolutionBtn === "true") {
            var scButtons = document.createElement("div");
            scButtons.classList.add("sqq-buttons");
            optionContainer.appendChild(scButtons);

            // TIP BUTTON (SC)
            if (scShowTipBtn === "true" && x.tipText) {
              var scTipBtn = document.createElement("button");
              scTipBtn.classList.add("sqq-mc-btn", "sqq-btn-secondary");
              scTipBtn.setAttribute('tabindex', '0');
              scTipBtn.innerHTML = x.txtShowTips;
              scTipBtn.style.fontFamily = fontFamily;
              scTipBtn.style.fontSize = fontSize + 'px';
              setImportant(scTipBtn, 'color', x.tipBtnCol);
              setImportant(scTipBtn, 'background-color', x.tipBtnBg);
              setImportant(scTipBtn, 'background-image', 'none');
              scTipBtn.setAttribute('aria-expanded', 'false');
              scTipBtn.setAttribute('aria-controls', widgetId + '-sc-tips');
              scButtons.appendChild(scTipBtn);

              var scDivTips = document.createElement("div");
              scDivTips.classList.add("sqq-tips");
              scDivTips.id = widgetId + '-sc-tips';
              scDivTips.style.fontFamily = fontFamily;
              scDivTips.style.fontSize = fontSize + 'px';
              scDivTips.style.color = x.tipAreaCol;
              scDivTips.style.backgroundColor = x.tipAreaBg;
              scDivTips.style.border = '1px solid ' + x.tipAreaBorder;
              optionContainer.appendChild(scDivTips);

              var scTipsVisible = false;
              scTipBtn.addEventListener('click', function() {
                scTipsVisible = !scTipsVisible;
                scTipBtn.setAttribute('aria-expanded', scTipsVisible ? 'true' : 'false');
                if (scTipsVisible) {
                  scDivTips.innerHTML = "<p>" + x.tipText + "</p>";
                  scDivTips.style.display = 'block';
                  scTipBtn.innerHTML = x.txtHideTips;
                } else {
                  scDivTips.style.display = 'none';
                  scTipBtn.innerHTML = x.txtShowTips;
                }
              });
            }

            // SOLUTION BUTTON (SC)
            if (scShowSolutionBtn === "true") {
              var scSolutionBtn = document.createElement("button");
              scSolutionBtn.classList.add("sqq-mc-btn", "sqq-btn-secondary");
              scSolutionBtn.setAttribute('tabindex', '0');
              scSolutionBtn.innerHTML = x.txtShowSolution;
              scSolutionBtn.style.fontFamily = fontFamily;
              scSolutionBtn.style.fontSize = fontSize + 'px';
              setImportant(scSolutionBtn, 'color', x.solutionBtnCol);
              setImportant(scSolutionBtn, 'background-color', x.solutionBtnBg);
              setImportant(scSolutionBtn, 'background-image', 'none');
              scSolutionBtn.setAttribute('aria-expanded', 'false');
              scSolutionBtn.setAttribute('aria-controls', widgetId + '-sc-solution');
              scButtons.appendChild(scSolutionBtn);

              var scDivSolution = document.createElement("div");
              scDivSolution.classList.add("sqq-solution");
              scDivSolution.id = widgetId + '-sc-solution';
              scDivSolution.style.fontFamily = fontFamily;
              scDivSolution.style.fontSize = fontSize + 'px';
              scDivSolution.style.color = x.solutionAreaCol;
              scDivSolution.style.backgroundColor = x.solutionAreaBg;
              scDivSolution.style.border = '1px solid ' + x.solutionAreaBorder;
              optionContainer.appendChild(scDivSolution);

              var scSolutionVisible = false;
              scSolutionBtn.addEventListener('click', function() {
                scSolutionVisible = !scSolutionVisible;
                scSolutionBtn.setAttribute('aria-expanded', scSolutionVisible ? 'true' : 'false');
                if (scSolutionVisible) {
                  scDivSolution.innerHTML = "<p>" + x.txtCorrectAnswers + ": <strong>" +
                    myQuestion[2] + "</strong></p>";
                  scDivSolution.style.display = 'block';
                  scSolutionBtn.innerHTML = x.txtHideSolution;
                } else {
                  scDivSolution.style.display = 'none';
                  scSolutionBtn.innerHTML = x.txtShowSolution;
                }
              });
            }
          }

        } else {
          // MULTIPLE-CHOICE MODE: click toggles selection, submit button checks

          var correctAnswers = myQuestion[2]; // array of correct answer texts
          var showTipBtn = x.showTipBtn;
          var showSolutionBtn = x.showSolutionBtn;

          // Reset question background to initial state
          function resetFeedback() {
            document.querySelector(`#${widgetId} .sqq-question`).style.backgroundColor = questionBg;
            document.querySelector(`#${widgetId} .sqq-question-text`).style.color = questionCol;
            submitBtn.disabled = false;
            submitBtn.setAttribute('aria-disabled', 'false');
          }

          // Toggle selection on click and re-enable submit
          for (let j = 0; j < nOpt; j++) {
            (function(idx) {
              var rowElMC = document.querySelector(`#${widgetId} #sqq-row-${lett[idx]}`);
              if (rowElMC) {
                rowElMC.addEventListener('click', function() {
                  this.classList.toggle('sqq-selected');
                  // Update background color based on selection state
                  var isSelected = this.classList.contains('sqq-selected');
                  this.style.backgroundColor = isSelected ? darkenColor(optionBg, 0.3) : optionBg;
                  // Update letter color based on selection state
                  var letterDiv = this.querySelector('.sqq-div-letter');
                  if (letterDiv) {
                    letterDiv.style.backgroundColor = this.classList.contains('sqq-selected') ? optionLabelHoverBg : optionLabelBg;
                  }
                  // Sync aria-checked with selection state
                  this.setAttribute('aria-checked', this.classList.contains('sqq-selected') ? 'true' : 'false');
                  // Re-enable submit when selection changes
                  if (submitBtn.disabled) {
                    resetFeedback();
                  }
                });
              }
            })(j);
          }

          // BUTTONS CONTAINER
          var mcButtons = document.createElement("div");
          mcButtons.classList.add("sqq-buttons");
          optionContainer.appendChild(mcButtons);

          // SUBMIT BUTTON
          var submitBtn = document.createElement("button");
          submitBtn.classList.add("sqq-mc-btn");
          submitBtn.setAttribute('tabindex', '0');
          submitBtn.innerHTML = x.txtSubmit;
          submitBtn.style.fontFamily = fontFamily;
          submitBtn.style.fontSize = fontSize + 'px';
          setImportant(submitBtn, 'color', x.navBtnCol);
          setImportant(submitBtn, 'background-color', x.navBtnBg);
          setImportant(submitBtn, 'background-image', 'none');
          setImportant(submitBtn, 'border-color', x.navBtnBg);
          mcButtons.appendChild(submitBtn);

          submitBtn.addEventListener('click', function() {
            var selectedRows = divWidget.querySelectorAll(`#${widgetId} .sqq-option-row.sqq-selected`);
            var selectedTexts = [];
            selectedRows.forEach(function(row) {
              var textEl = row.querySelector('.sqq-p-text');
              if (textEl) selectedTexts.push(textEl.innerHTML);
            });

            var sortedSelected = selectedTexts.slice().sort();
            var sortedCorrect = correctAnswers.slice().sort();

            var isMatch = sortedSelected.length === sortedCorrect.length &&
              sortedSelected.every(function(val, idx) { return val === sortedCorrect[idx]; });

            var correctCount = 0;
            var wrongCount = 0;
            selectedTexts.forEach(function(txt) {
              if (correctAnswers.indexOf(txt) !== -1) {
                correctCount++;
              } else {
                wrongCount++;
              }
            });
            var missedCount = correctAnswers.length - correctCount;

            if (isMatch) {
              isCorrect();
            } else {
              isWrong();
              var msg = x.txtFeedbackCorrectSelected.replace("{n}", correctCount).replace("{total}", correctAnswers.length);
              if (wrongCount > 0) {
                msg += "\n" + x.txtFeedbackWrongOptions.replace("{n}", wrongCount).replace("{option}", wrongCount === 1 ? x.txtOptionSingular : x.txtOptionPlural);
              }
              if (missedCount > 0) {
                msg += "\n" + x.txtFeedbackMissing.replace("{n}", missedCount).replace("{answer}", missedCount === 1 ? x.txtAnswerSingular : x.txtAnswerPlural);
              }
              // Delay alert so browser renders the color change first
              setTimeout(function() { alert(msg); }, 50);
            }

            // Disable until selection changes
            submitBtn.disabled = true;
            submitBtn.setAttribute('aria-disabled', 'true');
          });

          // TIP BUTTON
          if (showTipBtn === "true") {
            var tipBtn = document.createElement("button");
            tipBtn.classList.add("sqq-mc-btn", "sqq-btn-secondary");
            tipBtn.setAttribute('tabindex', '0');
            tipBtn.innerHTML = x.txtShowTips;
            tipBtn.style.fontFamily = fontFamily;
            tipBtn.style.fontSize = fontSize + 'px';
            setImportant(tipBtn, 'color', x.tipBtnCol);
            setImportant(tipBtn, 'background-color', x.tipBtnBg);
            setImportant(tipBtn, 'background-image', 'none');
            tipBtn.setAttribute('aria-expanded', 'false');
            tipBtn.setAttribute('aria-controls', widgetId + '-tips');
            mcButtons.appendChild(tipBtn);

            var divTips = document.createElement("div");
            divTips.classList.add("sqq-tips");
            divTips.id = widgetId + '-tips';
            divTips.style.fontFamily = fontFamily;
            divTips.style.fontSize = fontSize + 'px';
            divTips.style.color = x.tipAreaCol;
            divTips.style.backgroundColor = x.tipAreaBg;
            divTips.style.border = '1px solid ' + x.tipAreaBorder;
            optionContainer.appendChild(divTips);

            var tipText = x.tipText;
            var tipsVisible = false;
            tipBtn.addEventListener('click', function() {
              tipsVisible = !tipsVisible;
              tipBtn.setAttribute('aria-expanded', tipsVisible ? 'true' : 'false');
              if (tipsVisible) {
                if (tipText) {
                  divTips.innerHTML = "<p>" + tipText + "</p>";
                } else {
                  divTips.innerHTML = "<p>" + x.txtNumberOfCorrectAnswers + ": <strong>" +
                    correctAnswers.length + "</strong></p>";
                }
                divTips.style.display = 'block';
                tipBtn.innerHTML = x.txtHideTips;
              } else {
                divTips.style.display = 'none';
                tipBtn.innerHTML = x.txtShowTips;
              }
            });
          }

          // SOLUTION BUTTON
          if (showSolutionBtn === "true") {
            var solutionBtn = document.createElement("button");
            solutionBtn.classList.add("sqq-mc-btn", "sqq-btn-secondary");
            solutionBtn.setAttribute('tabindex', '0');
            solutionBtn.innerHTML = x.txtShowSolution;
            solutionBtn.style.fontFamily = fontFamily;
            solutionBtn.style.fontSize = fontSize + 'px';
            setImportant(solutionBtn, 'color', x.solutionBtnCol);
            setImportant(solutionBtn, 'background-color', x.solutionBtnBg);
            setImportant(solutionBtn, 'background-image', 'none');
            solutionBtn.setAttribute('aria-expanded', 'false');
            solutionBtn.setAttribute('aria-controls', widgetId + '-solution');
            mcButtons.appendChild(solutionBtn);

            var divSolution = document.createElement("div");
            divSolution.classList.add("sqq-solution");
            divSolution.id = widgetId + '-solution';
            divSolution.style.fontFamily = fontFamily;
            divSolution.style.fontSize = fontSize + 'px';
            divSolution.style.color = x.solutionAreaCol;
            divSolution.style.backgroundColor = x.solutionAreaBg;
            divSolution.style.border = '1px solid ' + x.solutionAreaBorder;
            optionContainer.appendChild(divSolution);

            var solutionVisible = false;
            solutionBtn.addEventListener('click', function() {
              solutionVisible = !solutionVisible;
              solutionBtn.setAttribute('aria-expanded', solutionVisible ? 'true' : 'false');
              if (solutionVisible) {
                divSolution.innerHTML = "<p>" + x.txtCorrectAnswers + ": <strong>" +
                  correctAnswers.join(", ") + "</strong></p>";
                divSolution.style.display = 'block';
                solutionBtn.innerHTML = x.txtHideSolution;
              } else {
                divSolution.style.display = 'none';
                solutionBtn.innerHTML = x.txtShowSolution;
              }
            });
          }
        }


      // end of renderValue Function
      },

      resize: function(width, height) {

        // TODO: code to re-render the widget with a new size

      }

    };
  }
});
