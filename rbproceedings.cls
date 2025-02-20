%%
%% Copyright 2020-2022 Takuto ASAKURA
%% Copyright 2023- Yoshitaka HARA
%%
%% This class is distributed under the MIT License.
%%

%% 依存パッケージ
\RequirePackage{expl3,xparse,l3keys2e}

%% クラス宣言
\NeedsTeXFormat{LaTeX2e}
\ProvidesExplPackage {rbproceedings} {2023-12-12} {1.0.0}
  {Japanese document class for the proceedings of rbproceedings}

%% メッセージ
\msg_new:nnn { rbproceedings } { disallowed-option }
  { Option~ '#1'~ is~ disallowed;~ skipping. }

%% (u)pTeX 用パッチ類
\clist_const:Nn \c__nlpr_ptex_requirements_clist { plautopatch }
\sys_if_engine_ptex:T
  {
    \RequirePackage { \c__nlpr_ptex_requirements_clist }
  }
\sys_if_engine_uptex:T
  {
    \RequirePackage { \c__nlpr_ptex_requirements_clist }
  }

%% クラスオプション
\bool_new:N \g_nlpr_english_bool

\clist_new:N \g__nlpr_options_clist
\clist_new:N \g__nlpr_disallowed_options_clist
\seq_new:N \g__nlpr_disallowed_options_seq

% jlreq に渡す
\clist_gset:Nn \g__nlpr_disallowed_options_clist
  {
    article, report, book, paper, fontsize, jafontsize, jafontscale,
    line_length, number_of_lines, head_space, foot_space, gutter, fore_edge,
    fore-edge, headfoot_verticalposition, headfoot_sidemargin, column_gap,
    baselineskip, linegap, hanging_punctuation, narrow_kanjiskip,
    sidenote_length, use_reverse_pagination, landscape, tate, oneside, twoside,
    oneclumn, twocolumn, titlepage, notitlepage, openright, openany
  }
\clist_map_inline:Nn \g__nlpr_disallowed_options_clist
  {
    \seq_gput_right:Nx \g__nlpr_disallowed_options_seq { \tl_to_str:n {#1} }
  }
\cs_new:Nn \__nlpr_process_class_option:
  {
    % 2020年に変更 \l_keys_key_tl -> \l_keys_key_str
    \cs_if_exist:NF \l_keys_key_str
      { \cs_set_eq:NN \l_keys_key_str \l_keys_key_tl }
    \seq_if_in:NoTF \g__nlpr_disallowed_options_seq { \l_keys_key_str }
      { \msg_warning:nnx { rbproceedings } { disallowed-option } { \l_keys_key_str } }
      { \clist_gput_right:No \g__nlpr_options_clist { \CurrentOption } }
  }

% オプション実行
\keys_define:nn { rbproceedings / option }
  {
    english .bool_gset:N = \g_nlpr_english_bool,
    english .default:n = true,
    unknown .code:n = \__nlpr_process_class_option:
  }
\ProcessKeysOptions { rbproceedings / option }
\PassOptionsToClass { \g__nlpr_options_clist } { jlreq }

%% 基本版面設計
% 規定オプションを指定して jlreq を読み込む
\LoadClass
  [
    paper=a4,            % 用紙サイズ
    twocolumn,           % 二段組
    fontsize=10pt,       % フォントサイズ
    baselineskip=1.5zh,  % 行送り
    head_space=3cm,      % 天
    foot_space=3cm,      % 地
    gutter=2cm,          % のど
    fore-edge=2cm,       % 小口
  ] { jlreq }

% ノンブル非表示
\pagestyle{empty}

% 欧文フォント（タイムズ系）
\RequirePackage[full]{textcomp}               % 記号類の補完
\RequirePackage[defaultsups]{newtxtext}       % 脚注記号は LaTeX 標準のまま
\RequirePackage[varqu,varl]{inconsolata}      % タイプライタ体
\RequirePackage[bigdelims,vvarbb]{newtxmath}  % 黒板太字は STIX
\RequirePackage[cal=boondoxo]{mathalfa}       % 花文字

%% タイトル
\group_begin:
\makeatletter
\gdef\@maketitle{%
  \newpage\null
  \vskip 2\baselineskip%
  \begin{center}%
  {\jlreq@keepbaselineskip{\LARGE}\sffamily\gtfamily\bfseries\@title\par}%
  \vskip\baselineskip
  {\jlreq@keepbaselineskip{\large}%
    \lineskip .5\zh
    \begin{tabular}[t]{c}%
      \@author
    \end{tabular}%
    \par
  }%
  \end{center}%
  \par
  \vskip\baselineskip
  \ifvoid\jlreq@abstractbox\else\unvbox\jlreq@abstractbox\fi
}
\group_end:

%% 英語対応
\bool_if:NT \g_nlpr_english_bool
  {
    \tl_set:Nn \abstractname { Abstract }
    \tl_set:Nn \contentsname { Table~ of~ Contents }
    \tl_set:Nn \refname { References }
    \tl_set:Nn \indexname { Index }
    \tl_set:Nn \listfigurename { List~ of~ Figures }
    \tl_set:Nn \figurename { Figure }
    \tl_set:Nn \listtablename { List~ of~ Tables }
    \tl_set:Nn \tablename { Table }
    \tl_set:cn { fnum@figure } { \figurename\nobreakspace\thefigure }
    \tl_set:cn { fnum@table } { \tablename\nobreakspace\thetable }
  }

%% 見出し
\ModifyHeading{section}{
  lines=2,
}

%% 参考文献
\renewenvironment{thebibliography}[1]{%
  \jlreq@oldfontcommand@enable
  \section*{\refname}%
  \@mkboth{\refname}{\refname}%
  \bibfont
  \list{\@biblabel{\@arabic\c@enumiv}}%
      {\settowidth\labelwidth{\@biblabel{#1}}%
      \labelsep=1\zw
      \leftmargin\labelwidth
      \advance\leftmargin\labelsep
      \itemindent=0pt
      \@openbib@code
      \usecounter{enumiv}%
      \let\p@enumiv\@empty
      \renewcommand\theenumiv{\@arabic\c@enumiv}}%
  \sloppy
  \clubpenalty4000
  \@clubpenalty\clubpenalty
  \widowpenalty4000%
  \sfcode`\.\@m
}{%
  \def\@noitemerr{\@latex@warning{Empty `thebibliography' environment}}%
  \endlist
  \jlreq@oldfontcommand@disable
}
\tl_set:Nn \bibfont { \small }

%% 各種寸法
\AtBeginDocument{
  \setlength{\abovedisplayskip}{6pt plus 3pt minus 3pt}
  \setlength{\belowdisplayskip}{6pt plus 3pt minus 3pt}
  \setlength{\floatsep}{6pt plus 2pt minus 2pt}
  \setlength{\textfloatsep}{10pt plus 2pt minus 4pt}
  \setlength{\intextsep}{6pt plus 2pt minus 2pt}
  \setlength{\dblfloatsep}{6pt plus 2pt minus 2pt}
  \setlength{\dbltextfloatsep}{10pt plus 2pt minus 4pt}
  \setlength{\abovecaptionskip}{.25\baselineskip}
  \setlength{\belowcaptionskip}{0pt}
}
\jlreqsetup{
  itemization_beforeafter_space={0pt,i=.25\baselineskip},
  caption_font={\small},  % キャプション
}

% vim: ft=expl3 nospell:
%% EOF
