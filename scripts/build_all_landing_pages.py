#!/usr/bin/env python3
"""
Build all SEO and GEO landing pages, homepages, sitemap.xml, and robots.txt for iScreenshot (极速截屏).
Generates:
1. 5 Pairs (EN + ZH) = 10 feature/download landing pages
2. website/index.html (Modern Quiet Native English Homepage)
3. website/zh.html (Modern Quiet Native Chinese Homepage)
4. website/sitemap.xml
5. website/robots.txt
"""
import os
import sys

sys.path.insert(0, '/Users/hobby/gitlab-source/cduyzhShot/scripts')
from generate_feature_pages import generate_page, OUTPUT_DIR, BASE_URL, REPO_URL, COMMON_CSS

pages_data = [
    # ── 1. Scrolling Long Screenshot ──────────────────────────────────────────
    {
        "slug": "features/scrolling-capture",
        "tag_en": "SCROLLING CAPTURE ENGINE",
        "tag_zh": "智能滚动长截图引擎",
        "title_en": "Mac Scrolling Screenshot Tool – Capture Full Webpages & Chat Logs | iScreenshot",
        "title_zh": "Mac 滚动长截图工具 - 智能多特征对齐长网页与聊天长图｜极速截屏",
        "meta_en": "Take pixel-perfect scrolling long screenshots on macOS without cloud uploads. Multi-row RGB feature alignment, automatic header/footer deduplication, seam recovery, and zero lag.",
        "meta_zh": "macOS 原生滚动长截图工具，本地极速拼接。支持长网页、代码文件与即时通讯长聊天记录，多行特征对齐自动剔除重复表头表尾，失配自动小步接回，完全离线运行。",
        "h1_en": "Native macOS Scrolling Long Screenshot with Intelligent Feature Stitching",
        "h1_zh": "Mac 原生滚动长截图：多特征对齐与智能接缝恢复",
        "lead_en": "Capture long web pages, lengthy source code files, and infinite chat histories in one seamless, high-resolution image. Powered by Apple ScreenCaptureKit and local RGB feature matching with zero memory bloat.",
        "lead_zh": "长网页、超长源代码与连续聊天记录一键生成整张超高清长图。基于 Apple ScreenCaptureKit 异步采样与自研 RGB 纵向特征对齐算法，拒绝破图与内存泄漏，完全免费开源。",
        "bc_en": [("Features", f"{BASE_URL}/#features"), ("Scrolling Capture", "")],
        "bc_zh": [("核心特性", f"{BASE_URL}/zh.html#features"), ("滚动长截图", "")],
        "cta_title_en": "Capture your first long screenshot in seconds",
        "cta_title_zh": "立即体验丝滑无感的原生滚动长截图",
        "cta_desc_en": "Download iScreenshot for macOS 14+ and capture entire pages with a single shortcut ⌥S.",
        "cta_desc_zh": "免费下载适用于 macOS 14+ 的 iScreenshot，使用全局快捷键 ⌥S 即可一键拼接任意超长内容。",
        "sections_en": """
    <section class="content-section">
      <h2 class="section-heading">The Long-Standing Pain of Capturing Long Content on Mac</h2>
      <div class="prose">
        <p>Taking screenshots of long pages on macOS has traditionally been frustrating. Built-in system tools like <kbd class="kbd">⌘⇧4</kbd> only capture what fits inside the physical display viewport. Browser extensions only work inside Safari or Chrome, completely failing when you need to capture long chat histories in Slack, Telegram, or WeChat, or nested source code files inside Xcode and VS Code.</p>
        <p>Paid utilities often charge recurring subscriptions just for basic stitching, while poorly implemented stitching tools suffer from misaligned text lines, distorted graphics, repeated sticky headers, and excessive memory consumption that freezes your system.</p>
      </div>

      <div class="card">
        <div class="card-header">
          <span class="card-title">How iScreenshot Solves Long Capture</span>
          <span class="term-pill mono">ScreenCaptureKit + Sub-Pixel Stitching</span>
        </div>
        <div class="prose">
          <ul style="padding-left: 20px; line-height: 1.8;">
            <li><strong>Universal Desktop Capture</strong>: Works seamlessly on any scrollable window across macOS — browser tabs, code editors, terminal logs, spreadsheets, and chat threads.</li>
            <li><strong>Multi-Row RGB Feature Matching</strong>: Samples multiple vertical columns of color landmarks across frames to compute exact sub-pixel displacements.</li>
            <li><strong>Duplicate Header & Footer Removal</strong>: Automatically detects fixed floating headers and sticky bottom toolbars, keeping them exactly once.</li>
            <li><strong>Bounded Memory Architecture</strong>: Only keeps incremental image strips and active comparison frames, capping peak memory to ~40 MP to safeguard system stability.</li>
          </ul>
        </div>
      </div>
    </section>

    <section class="content-section">
      <h2 class="section-heading">How to Capture Long Screenshots Step-by-Step</h2>
      <div class="step-list">
        <div class="step-item">
          <div class="step-num">1</div>
          <div class="step-content">
            <h4>Initiate Capture</h4>
            <p>Press <kbd class="kbd">⌥S</kbd> (Option + S) or trigger a standard selection with <kbd class="kbd">⌃A</kbd> and click the <strong>Long Screenshot</strong> button in the floating toolbar.</p>
          </div>
        </div>
        <div class="step-item">
          <div class="step-num">2</div>
          <div class="step-content">
            <h4>Scroll Manually or Click Auto-Capture</h4>
            <p>Scroll naturally using your trackpad or mouse wheel. With macOS Accessibility permission granted, simply click <strong>Capture Down</strong> or <strong>Capture Up</strong> to scroll and stitch automatically.</p>
          </div>
        </div>
        <div class="step-item">
          <div class="step-num">3</div>
          <div class="step-content">
            <h4>Finish and Export</h4>
            <p>Press <kbd class="kbd">Enter</kbd> or click the green checkmark. The final composite image is atomically generated in the background and copied straight to your clipboard with high-DPI Retina fidelity.</p>
          </div>
        </div>
      </div>
    </section>

    <section class="content-section">
      <h2 class="section-heading">Intelligent Seam Recovery & Fault Tolerance</h2>
      <div class="prose">
        <p>If you accidentally scroll too fast or skip past content, iScreenshot's dynamic seam recovery kicks in immediately. Instead of producing a broken or duplicated image, the engine halts stitching, retains the last verified overlapping frame, and presents a <strong>Help me rejoin</strong> guide.</p>
        <p>Simply nudge the content slightly until the overlapping features realign, and stitching resumes seamlessly without discarding previous progress.</p>
      </div>
    </section>
""",
        "sections_zh": """
    <section class="content-section">
      <h2 class="section-heading">Mac 长图截取的痛点与解决方案</h2>
      <div class="prose">
        <p>在 Mac 上截取长内容一直充满痛点。系统自带的 <kbd class="kbd">⌘⇧4</kbd> 只能截取当前显示屏可见区域；浏览器插件只能处理网页，一旦遇到微信、飞书、Slack 聊天记录，或者 Xcode、VS Code 中的长代码文件便无能为力。</p>
        <p>很多市面商业软件不仅要求按年订阅昂贵会员，且拼接算法粗糙，频繁发生文字错位断裂、图片撕裂、固定导航栏重复刷屏，甚至在截取超长页面时爆内存导致系统卡死崩溃。</p>
      </div>

      <div class="card">
        <div class="card-header">
          <span class="card-title">iScreenshot 极速截屏的核心技术突破</span>
          <span class="term-pill mono">ScreenCaptureKit 原生异步采样</span>
        </div>
        <div class="prose">
          <ul style="padding-left: 20px; line-height: 1.8;">
            <li><strong>全系统任意视窗支持</strong>：不仅支持 Safari 与 Chrome，更完美支持原生聊天应用、文档视窗、终端与代码编辑器。</li>
            <li><strong>多行多列 RGB 纵向特征动态对齐</strong>：基于高灵敏度图像特征置信度计算垂直位移，亚像素级无缝缝合。</li>
            <li><strong>智能剔除吸顶与悬浮元素</strong>：自动比对固定页眉与页尾，智能判定并在最终大图中仅保留一次。</li>
            <li><strong>严格内存安全上限</strong>：采用增量条带缓存模型，全链路限制在约 4000 万像素安全阈值，防止高负荷占用。</li>
          </ul>
        </div>
      </div>
    </section>

    <section class="content-section">
      <h2 class="section-heading">三步上手滚动长截图</h2>
      <div class="step-list">
        <div class="step-item">
          <div class="step-num">1</div>
          <div class="step-content">
            <h4>快捷键随处唤醒</h4>
            <p>按下全局快捷键 <kbd class="kbd">⌥S</kbd>（Option + S），或在普通区域截图工具栏中点击“长截图”按钮锁定滚动区域。</p>
          </div>
        </div>
        <div class="step-item">
          <div class="step-num">2</div>
          <div class="step-content">
            <h4>平滑滚动或一键自动滚屏</h4>
            <p>使用触控板双指或鼠标滚轮自然向下滚动。开启辅助功能权限后，可直接点击“向下捕获”或“向上捕获”，应用将自动平滑滚动并实时抓帧拼接。</p>
          </div>
        </div>
        <div class="step-item">
          <div class="step-num">3</div>
          <div class="step-content">
            <h4>回车一键复制大图</h4>
            <p>滚动完毕后按 <kbd class="kbd">Enter</kbd> 或点击完成。后台将在子线程原子合成最终高清晰度 PNG，瞬间写入系统剪贴板并推送完成通知。</p>
          </div>
        </div>
      </div>
    </section>

    <section class="content-section">
      <h2 class="section-heading">智能接缝恢复：告别拼接错位破图</h2>
      <div class="prose">
        <p>若用户滚动过快或画面出现突变导致短暂失配，iScreenshot 会立即启动接缝恢复保护。拼接引擎不会胡乱输出错位破图，而是暂停拼接并提示<strong>“帮我接回”</strong>。</p>
        <p>用户只需轻微回滚几行内容，特征算法重新捕捉到锚点后即可自动恢复拼接，此前截取的所有内容完好无损。</p>
      </div>
    </section>
""",
        "faq_en": [
            {
                "q": "Does iScreenshot require Accessibility permissions for scrolling capture?",
                "a": "Manual scrolling capture works completely without Accessibility permission. You can freely scroll with your trackpad or mouse. Accessibility permission is only required if you want iScreenshot to automatically scroll the page for you using the 'Capture Down' and 'Capture Up' buttons."
            },
            {
                "q": "Can I take scrolling screenshots of native desktop apps like Slack or Xcode?",
                "a": "Yes! Because iScreenshot captures frames directly via macOS ScreenCaptureKit at the OS display layer, it works on any native Mac application, not just web browsers."
            },
            {
                "q": "How does it prevent fixed headers from appearing multiple times?",
                "a": "The stitching engine analyzes repetitive pixel blocks at the top and bottom of consecutive frames. When a fixed header is identified, it is anchored and ignored in intermediate scroll strips, appearing only once at the top of the final image."
            },
            {
                "q": "Is there a limit to how long the screenshot can be?",
                "a": "iScreenshot incorporates a safety memory boundary (~40 megapixels, equivalent to over 15 full 4K screen lengths) to safeguard your Mac's system memory. This easily accommodates even the longest web articles and chat logs."
            }
        ],
        "faq_zh": [
            {
                "q": "使用滚动长截图必须开启辅助功能权限吗？",
                "a": "不需要！手动滚动模式完全无需辅助功能权限，只需用触控板或鼠标正常滑动即可拼接。只有使用“向上自动捕获”与“向下自动捕获”由软件代劳滚屏时，才需要系统辅助功能权限。"
            },
            {
                "q": "支持截取微信、飞书或代码编辑器的长图吗？",
                "a": "完全支持！iScreenshot 基于 macOS 系统级底层 ScreenCaptureKit 捕获视窗画面，不仅适用于网页，任何拥有滚动条的桌面原生软件均可平滑截取长图。"
            },
            {
                "q": "固定在顶部的导航栏（Sticky Header）会重复出现在长图里吗？",
                "a": "不会。iScreenshot 的图像特征算法会自动识别顶部与底部的固定悬浮组件，在中间增量滚动帧中自动滤除重复背景，在最终长图中保持唯一的顶部展示。"
            },
            {
                "q": "长截图有长度限制吗？",
                "a": "为了保护系统内存稳定，iScreenshot 设定了约 4000 万像素的超大安全容量，相当于 15 块以上 4K 屏幕的连续高度，完全能满足超长技术文档与连续聊天记录的截取需求。"
            }
        ]
    },

    # ── 2. Screenshot Studio & Mockups ─────────────────────────────────────────
    {
        "slug": "features/screenshot-studio",
        "tag_en": "SCREENSHOT STUDIO & MOCKUP",
        "tag_zh": "截图美化工作室与样机外壳",
        "title_en": "Mac Screenshot Mockup Studio – Window Frames & Gradient Backgrounds | iScreenshot",
        "title_zh": "Mac 截图美化工作室 - macOS 样机外框、精选渐变与阴影｜极速截屏",
        "meta_en": "Transform raw macOS screenshots into studio-grade marketing graphics. Native macOS light/dark frames, modern browser chrome, smart Gaussian background blur, and squircle corners.",
        "meta_zh": "为 Mac 截图套上设计级精美外框与渐变背景。原生 macOS 视窗外框、现代浏览器外壳、主体智能高斯毛玻璃、超椭圆倒角与弥散阴影，截图直出社交媒体画报。",
        "h1_en": "Turn Raw Screenshots into Marketing-Ready Visuals Instantly",
        "h1_zh": "截图秒变设计级画报：视窗样机外壳、精美渐变与阴影",
        "lead_en": "Create stunning product mockups, changelog illustrations, and social media posts directly on your Mac. Choose from macOS window frames, browser chrome, content-aware blurred backdrops, and custom aspect ratios with one-click export.",
        "lead_zh": "一键为截图生成精美社交分享图与产品宣传样机。提供 macOS 原生浅色/深色视窗、Safari/Chrome 极简浏览器外框、基于截图主体的智能动态毛玻璃与定制画幅，支持自动套用与无损高清导出。",
        "bc_en": [("Features", f"{BASE_URL}/#features"), ("Screenshot Studio", "")],
        "bc_zh": [("核心特性", f"{BASE_URL}/zh.html#features"), ("截图美化工作室", "")],
        "cta_title_en": "Start beautifying your screenshots today",
        "cta_title_zh": "让每一张截图都拥有设计级品质",
        "cta_desc_en": "Download iScreenshot and transform boring screenshots into eye-catching product artwork.",
        "cta_desc_zh": "免费下载 iScreenshot，无需借助外部设计工具，在 macOS 菜单栏直接产出高质量营销配图。",
        "sections_en": """
    <section class="content-section">
      <h2 class="section-heading">Why Default Screenshots Don't Cut It Anymore</h2>
      <div class="prose">
        <p>Raw screenshots with sharp rectangular edges and cluttered backgrounds look unprofessional on Twitter/X, LinkedIn, blog posts, and slide decks. To make graphics presentable, developers and founders often have to upload private images to third-party web tools like Shots.so, or pay hefty monthly subscriptions for apps like Xnapper.</p>
        <p><strong>iScreenshot Studio</strong> is natively integrated right into your macOS workflow. Press <kbd class="kbd">E</kbd> or <kbd class="kbd">⌥E</kbd> anytime to load your capture into a studio-grade layout editor powered by native GPU hardware acceleration.</p>
      </div>

      <div class="card">
        <div class="card-header">
          <span class="card-title">Studio Feature Highlights</span>
          <span class="term-pill mono">Native AppKit / Metal Rendering</span>
        </div>
        <div class="prose">
          <ul style="padding-left: 20px; line-height: 1.8;">
            <li><strong>5 Crafted Mockup Frames</strong>: Frameless pure mode, macOS Light window with Retina traffic light controls, macOS Dark obsidian, Browser Light with minimal Safari-style address bar, and Browser Dark.</li>
            <li><strong>Content-Aware Gaussian Blur</strong>: Upscales and blurs your screenshot itself to generate an impeccably color-harmonized backdrop.</li>
            <li><strong>Curated Gradient Wallpapers</strong>: Includes Sunrise Dawn, Aurora Borealis, Sunset Glow, Ocean Deep, and Titanium Dark.</li>
            <li><strong>Precision Geometry Controls</strong>: Continuous 0–100 px canvas padding, 0–40 px squircle corner radius, and multi-layer diffuse drop shadows (None, Soft, Deep).</li>
            <li><strong>Standard Aspect Ratio Presets</strong>: Auto, 1:1 Square, 4:3 Classic, 16:9 Landscape, 9:16 Story, and 3:4 Feed format.</li>
          </ul>
        </div>
      </div>
    </section>

    <section class="content-section">
      <h2 class="section-heading">The Auto-Beautify Global Pipeline</h2>
      <div class="prose">
        <p>Hate repeating the same editing steps every time you share a screenshot? iScreenshot lets you configure your aesthetic template once in <strong>Settings → Beautification</strong>.</p>
        <p>When <strong>Auto-Beautify Subsequent Captures</strong> is enabled, every screenshot you take automatically inherits your chosen frame, padding, and background upon pressing Enter. Your clipboard receives a polished, social-ready image immediately without ever opening the Studio window.</p>
      </div>
    </section>

    <section class="content-section">
      <h2 class="section-heading">Local Privacy Guarantee: 100% Offline Rendering</h2>
      <div class="prose">
        <p>Unlike web-based mockup generators that upload your confidential dashboard metrics, internal source code, and customer records to remote cloud servers, iScreenshot processes all graphics locally on your device. Zero bytes leave your Mac.</p>
      </div>
    </section>
""",
        "sections_zh": """
    <section class="content-section">
      <h2 class="section-heading">为什么普通截图无法满足高质量分发需求</h2>
      <div class="prose">
        <p>在推特/X、小红书、产品发布日志（Changelog）、博客文章与演示文稿中，边缘生硬、缺乏层次的原始截图往往显得粗糙单调。许多开发者不得不将敏感截图上传到三方在线样机网站，或者忍受高昂订阅费购买商业软件。</p>
        <p><strong>iScreenshot 美化工作室</strong> 将顶级设计排版能力完整内置于 macOS 原生工作流中。截屏时按 <kbd class="kbd">E</kbd>，或平时随时按 <kbd class="kbd">⌥E</kbd> 载入剪贴板图片，瞬间唤出金属质感美化调色台。</p>
      </div>

      <div class="card">
        <div class="card-header">
          <span class="card-title">美化工作室核心能力清单</span>
          <span class="term-pill mono">GPU 硬件加速渲染</span>
        </div>
        <div class="prose">
          <ul style="padding-left: 20px; line-height: 1.8;">
            <li><strong>五种精制视窗样机外壳</strong>：纯净无框、macOS 浅色金属光泽、macOS 深色黑曜石、现代浏览器浅色（仿 Safari 极简地址栏）与浏览器深色。</li>
            <li><strong>智能动态景深毛玻璃</strong>：利用截图主体计算多阶高斯模糊背景，色彩基调天然与画面浑然一体。</li>
            <li><strong>精选高颜值渐变壁纸</strong>：内置晨曦暮光、极光微芒、薄暮暖霞、深海幽蓝与钛金灰黑等主题。</li>
            <li><strong>几何微操控制</strong>：0～100px 留白边距无极滑动、0～40px 超椭圆（Squircle）柔和圆角，以及柔和/深邃双层自然弥散阴影。</li>
            <li><strong>社交平台标准画幅比例</strong>：自适应 Auto、1:1 正方图、4:3 经典、16:9 横屏视频封面、9:16 移动端故事与 3:4 社交图文排版。</li>
          </ul>
        </div>
      </div>
    </section>

    <section class="content-section">
      <h2 class="section-heading">一键开启：后续截图自动套用美化</h2>
      <div class="prose">
        <p>厌烦了每次截图后都要重复调整样机和背景？iScreenshot 支持全局<strong>“后续截图自动套用”</strong>流水线。</p>
        <p>只需在偏好设置中调出心仪的预设方案并开启自动套用，之后日常截图按下回车完成时，复制到剪贴板中的即是已套好样机、渐变背景与柔和阴影的社交级成品图，无需每次手动打开美化面板。</p>
      </div>
    </section>

    <section class="content-section">
      <h2 class="section-heading">绝对隐私：100% 本地渲染，数据绝不上云</h2>
      <div class="prose">
        <p>截图常常包含商业后台数据、用户私信或内部未开源代码。与必须将图片上传至第三方服务器处理的在线样机工具不同，iScreenshot 基于本地 AppKit 与 Metal 原生管线直接合成图像，不发任何网络请求，真正保障企业与个人数据隐私。</p>
      </div>
    </section>
""",
        "faq_en": [
            {
                "q": "Can I load images from my clipboard into the Studio without taking a screenshot?",
                "a": "Yes! Simply press ⌥E (Option + E) from anywhere or select 'Image Studio' from the menu bar. If you have an image in your clipboard, it opens automatically in the Studio. You can also pick any local PNG, JPEG, or WebP file from disk."
            },
            {
                "q": "Does Auto-Beautify slow down the capture workflow?",
                "a": "Not at all. The rendering pipeline is written in native Swift and executes on background GPU queues. High-DPI mockups are synthesized in milliseconds, and completing a capture with Enter remains instantaneous."
            },
            {
                "q": "Can I export transparent PNGs with mockups and shadows?",
                "a": "Yes! Select the 'Transparent' checkerboard background swatch. iScreenshot outputs a transparent PNG preserving alpha transparency for drop shadows and rounded corners."
            }
        ],
        "faq_zh": [
            {
                "q": "可以在不重新截图的情况下直接美化剪贴板中的图片吗？",
                "a": "完全可以！随时按下全局快捷键 ⌥E（Option + E），或在菜单栏面板中点击“图片美化”，如果剪贴板中有图片（如来自 Figma、浏览器或其他软件），将自动载入工作室中，也可直接选择本地磁盘图片。"
            },
            {
                "q": "开启“自动套用美化”会导致截图变卡吗？",
                "a": "绝不。合成管线基于原生 Swift 并在后台 GPU 线程执行，整张高清样机的渲染耗时仅需数毫秒，按下 Enter 依旧瞬间复制入剪贴板，使用体验轻盈畅快。"
            },
            {
                "q": "支持导出保留透明通道的透明背景样机图吗？",
                "a": "支持。只需在背景色板中选择“透明（透明棋盘格）”，导出的 PNG 图片即完整保留弥散阴影与视窗圆角的 Alpha 透明通道，非常适合贴入 Keynote 或网站页面。"
            }
        ]
    },

    # ── 3. Screen Recorder with System Audio ───────────────────────────────────
    {
        "slug": "features/screen-recorder",
        "tag_en": "SCREEN RECORDER WITH SYSTEM AUDIO",
        "tag_zh": "高清录屏与系统声音内录",
        "title_en": "Mac Screen Recorder with System Audio – ScreenCaptureKit Native | iScreenshot",
        "title_zh": "Mac 录屏软件支持系统声音内录 - ScreenCaptureKit 原生免驱动｜极速截屏",
        "meta_en": "Record macOS screen and system audio simultaneously without installing virtual sound card drivers like BlackHole or Soundflower. 60 FPS H.264/HEVC, zero audio lag, free & open source.",
        "meta_zh": "macOS 原生高清录屏工具，支持系统声音内录。彻底告别 BlackHole / Soundflower 等虚拟声卡驱动，ScreenCaptureKit 底层直驱 48kHz 立体声录制，60 帧无损输出，轻量开源。",
        "h1_en": "Record macOS Screen & System Audio with Zero Extra Drivers",
        "h1_zh": "Mac 高清选区录屏：免装虚拟声卡驱动，系统声音完美内录",
        "lead_en": "Record any custom region or full screen with crisp 60 FPS video and crystal-clear internal computer sound. Powered directly by macOS ScreenCaptureKit with zero driver friction and zero latency.",
        "lead_zh": "随心截取任意矩形区域或全屏录制。基于 macOS ScreenCaptureKit 原生音频总线，无需安装配置复杂的虚拟声卡驱动，内录扬声器全部声音，60 FPS 高帧率硬编，录毕自动保存并复制路径。",
        "bc_en": [("Features", f"{BASE_URL}/#features"), ("Screen Recorder", "")],
        "bc_zh": [("核心特性", f"{BASE_URL}/zh.html#features"), ("高清录屏", "")],
        "cta_title_en": "Experience hassle-free Mac screen recording",
        "cta_title_zh": "体验真正免驱动的原生系统声音内录",
        "cta_desc_en": "Download iScreenshot and record 60 FPS videos with internal audio with shortcut ⌃[.",
        "cta_desc_zh": "免费下载 iScreenshot，按 ⌃[ 快捷键一键开启高清内录，告别繁琐的虚拟声卡配置。",
        "sections_en": """
    <section class="content-section">
      <h2 class="section-heading">The Mac Internal Audio Recording Dilemma</h2>
      <div class="prose">
        <p>For more than a decade, macOS users trying to record a video with computer audio faced a nightmare. Apple's built-in QuickTime Player deliberately disables system sound recording, forcing users to download third-party virtual audio kernel extensions or HAL plugins such as Soundflower, BlackHole, or Loopback.</p>
        <p>These virtual drivers often break after macOS major updates, cause audio routing misconfigurations where your Mac suddenly goes silent, and introduce frustrating audio-video desync.</p>
      </div>

      <div class="card">
        <div class="card-header">
          <span class="card-title">How iScreenshot Reinvents Screen Recording</span>
          <span class="term-pill mono">ScreenCaptureKit Native Audio Bus</span>
        </div>
        <div class="prose">
          <ul style="padding-left: 20px; line-height: 1.8;">
            <li><strong>Direct Kernel Audio Tap</strong>: Directly configures Apple's ScreenCaptureKit engine with <code>capturesAudio = true</code>, capturing 48 kHz stereo PCM sound directly from the audio rendering pipeline.</li>
            <li><strong>Zero Drivers to Install</strong>: Requires absolutely no kernel extensions, HAL plugins, or virtual audio devices. Works out of the box on macOS 14 Sonoma and macOS 15+ Sequoia.</li>
            <li><strong>Hardware-Accelerated 60 FPS Video</strong>: Leverages Apple Silicon Media Engine and Intel VideoToolbox via <code>AVAssetWriter</code> for efficient H.264 / HEVC video compression.</li>
            <li><strong>Odd Resolution Alignment</strong>: Automatically adjusts odd-width and odd-height custom rectangles to even pixel boundaries, preventing video encoder green borders or dimension errors.</li>
          </ul>
        </div>
      </div>
    </section>

    <section class="content-section">
      <h2 class="section-heading">Recording Controls Designed for Productivity</h2>
      <div class="prose">
        <p>iScreenshot features a distraction-free, floating recording controller. Once recording begins, you get a clean 3-second visual countdown, followed by an unobtrusive floating bar displaying real-time elapsed time, active recording status, and an instant Stop button.</p>
        <p>When you finish recording, the MP4 file is written directly to your <code>~/Downloads</code> folder, the full file path is placed into your clipboard, and a system notification alerts you with a 1-click 'Show in Finder' action.</p>
      </div>
    </section>
""",
        "sections_zh": """
    <section class="content-section">
      <h2 class="section-heading">困扰 Mac 用户十余年的系统声音录制难题</h2>
      <div class="prose">
        <p>十多年来，Mac 用户想要在录屏时录下电脑发出的声音极其困难。系统内置的 QuickTime Player 故意锁死系统声音内录通道，迫使用户去折腾 Soundflower、BlackHole、Loopback 等第三方虚拟声卡驱动。</p>
        <p>这些驱动不仅配置复杂，每次 macOS 大版本升级都有可能失效崩溃，甚至经常造成扬声器静音或严重的音画不同步问题。</p>
      </div>

      <div class="card">
        <div class="card-header">
          <span class="card-title">iScreenshot 原生录屏解决方案</span>
          <span class="term-pill mono">ScreenCaptureKit 音频底层直驱</span>
        </div>
        <div class="prose">
          <ul style="padding-left: 20px; line-height: 1.8;">
            <li><strong>系统级原生音频采样</strong>：直接调用 Apple 官方 ScreenCaptureKit 框架（<code>capturesAudio = true</code>），以 48kHz 立体声采样率直接内录扬声器声轨。</li>
            <li><strong>零驱动安装依赖</strong>：彻底告别虚拟声卡驱动与内核扩展，即装即用，全面适配 macOS 14 Sonoma 与 macOS 15+ Sequoia。</li>
            <li><strong>60 FPS 硬件级流畅硬编</strong>：基于 <code>AVAssetWriter</code> 与 Apple 芯片媒体引擎硬件加速，低功耗输出 1080P/4K 高清 MP4 视频。</li>
            <li><strong>奇数分辨率自动对齐</strong>：自由拉拽的任意选区若产生奇数宽高，算法自动智能对齐至偶数像素边缘，根除硬件编码器绿边与报错。</li>
          </ul>
        </div>
      </div>
    </section>

    <section class="content-section">
      <h2 class="section-heading">轻盈优雅的录制交互设计</h2>
      <div class="prose">
        <p>按下快捷键 <kbd class="kbd">⌃[</kbd>（Control + [）即可一键开录。开录前伴随清晰的 3 秒倒计时提醒，录制过程中呈现小巧精悍的常驻浮条，展示录制时长、呼吸红点与结束按钮。</p>
        <p>点击停止或再次按下 <kbd class="kbd">⌃[</kbd>，视频自动保存至本地“下载”文件夹，文件路径直接写入剪贴板，右下角弹出系统通知方便一键在访达中定位。</p>
      </div>
    </section>
""",
        "faq_en": [
            {
                "q": "Why does QuickTime require BlackHole while iScreenshot does not?",
                "a": "QuickTime uses legacy CoreAudio recording APIs that do not support capturing aggregate system output. iScreenshot is built from scratch on modern macOS 14+ ScreenCaptureKit APIs, which grant authorized native applications direct access to the audio rendering bus."
            },
            {
                "q": "Can I record my microphone voice while recording system sound?",
                "a": "Yes! Granting the optional Microphone permission allows iScreenshot to blend your vocal commentary with system computer audio into a unified stereo audio track."
            },
            {
                "q": "Does 60 FPS recording cause high CPU or battery drain?",
                "a": "No. By utilizing Apple's hardware VideoToolbox and ScreenCaptureKit, video frames and audio buffers are encoded directly on Apple Silicon media engines, keeping CPU usage below 5%."
            }
        ],
        "faq_zh": [
            {
                "q": "为什么 QuickTime 录音需要 BlackHole 而 iScreenshot 完全不用？",
                "a": "QuickTime 使用的是传统的 CoreAudio 输入 API，无法直接抓取系统渲染总线；而 iScreenshot 是专为 macOS 14+ 打造的原生工具，直接采用了 Apple 最新推出的 ScreenCaptureKit，底层原生支持内录系统扬声器声音。"
            },
            {
                "q": "录制系统声音的同时可以录制麦克风人声吗？",
                "a": "可以。授予应用麦克风权限后，iScreenshot 能够将麦克风人声与电脑内部声音在本地高效混流，输出同一轨道的高清立体声音频。"
            },
            {
                "q": "60 帧高清录屏会导致发热或耗电严重吗？",
                "a": "绝不。得益于 Apple 芯片硬件媒体编解码引擎（VideoToolbox）与原生管线优化，录屏期间 CPU 占用率通常不足 5%，发热轻微，续航无忧。"
            }
        ]
    },

    # ── 4. Retina Pixel Magnifier & Color Picker ──────────────────────────────
    {
        "slug": "features/pixel-color-picker",
        "tag_en": "RETINA PIXEL MAGNIFIER & COLOR PICKER",
        "tag_zh": "视网膜像素级放大镜与取色器",
        "title_en": "Retina Pixel Magnifier & Hex Color Picker for Mac | iScreenshot",
        "title_zh": "Mac 像素级放大镜与 Hex/RGB 取色器 - 前端与设计利器｜极速截屏",
        "meta_en": "Inspect screen pixels at 4x magnification with live RGB Hex values, cursor crosshairs, and sub-pixel dimensions. Press C to copy color codes instantly on any macOS display.",
        "meta_zh": "专为前端工程师与 UI 设计师打造的 Mac 像素级放大镜取色器。4x Retina 放大网格、中心精准准星、实时 Hex 与 RGB 色值读数，按 C 键秒拷颜色代码。",
        "h1_en": "Pixel-Level Precision for Designers & Developers on macOS",
        "h1_zh": "4x 视网膜像素级放大镜与即时 Hex/RGB 取色器",
        "lead_en": "Never miss a sub-pixel alignment or color mismatch again. iScreenshot includes an integrated 4x Retina magnifier with instantaneous color sampling and single-key clipboard export.",
        "lead_zh": "彻底解决 UI 还原度微调与精准取色痛点。4x 视网膜高清放大网格、中心十字准星、精确坐标与尺寸标尺，实时输出标准十六进制与 RGB 数值，一键复制进开发工具。",
        "bc_en": [("Features", f"{BASE_URL}/#features"), ("Color Picker", "")],
        "bc_zh": [("核心特性", f"{BASE_URL}/zh.html#features"), ("放大镜取色器", "")],
        "cta_title_en": "Pick colors with surgical precision",
        "cta_title_zh": "体验像素级精准的屏幕取色利器",
        "cta_desc_en": "Download iScreenshot and inspect any pixel on your Mac screen with shortcut ⌃A and key C.",
        "cta_desc_zh": "免费下载 iScreenshot，按 ⌃A 唤醒截屏，鼠标所到之处即显 4 倍像素网格与 Hex 色值。",
        "sections_en": """
    <section class="content-section">
      <h2 class="section-heading">Designed for High-DPI Retina Displays</h2>
      <div class="prose">
        <p>Modern Mac screens pack millions of pixels into compact spaces. Identifying a 1-pixel CSS border misalignment, verifying gradient steps, or grabbing a specific brand hex code with the human eye is notoriously difficult on Retina and Liquid Retina XDR displays.</p>
        <p>iScreenshot integrates a high-speed, sub-pixel magnifying loupe directly into the screenshot capture interface, giving designers and engineers surgical visual inspection capabilities.</p>
      </div>

      <div class="card">
        <div class="card-header">
          <span class="card-title">Magnifier & Eyedropper Specs</span>
          <span class="term-pill mono">4x Retina Grid + Live Hex Readout</span>
        </div>
        <div class="prose">
          <ul style="padding-left: 20px; line-height: 1.8;">
            <li><strong>4x Optical Retina Magnification</strong>: Crisp zoomed-in view of individual screen pixels with grid demarcation and center target crosshair.</li>
            <li><strong>Dual Color Readout</strong>: Displays uppercase Hex color code (e.g. <code>#3B82F6</code>) alongside exact RGB integer components.</li>
            <li><strong>Instant 'C' Key Copy</strong>: Press <kbd class="kbd">C</kbd> at any time to copy the current hovered pixel's Hex value directly to your clipboard without leaving capture mode.</li>
            <li><strong>Sub-Pixel Coordinate HUD</strong>: Live readout of current X/Y display coordinates and width/height dimensions.</li>
          </ul>
        </div>
      </div>
    </section>

    <section class="content-section">
      <h2 class="section-heading">Zero-Latency Desktop HUD</h2>
      <div class="prose">
        <p>The magnifier follows your cursor smoothly across multiple monitors, handling wide-gamut Display P3 and sRGB color profiles accurately. When combined with keyboard arrow keys, you can nudge the selection by single pixels to achieve 100% design fidelity.</p>
      </div>
    </section>
""",
        "sections_zh": """
    <section class="content-section">
      <h2 class="section-heading">专为高分屏时代的前端与 UI 设计师打造</h2>
      <div class="prose">
        <p>在 Retina 与 Liquid Retina XDR 高密视网膜屏幕上，单像素（1px）仅有发丝细小。核对前端页面 1px 边框错位、检查细微渐变过渡或精确拾取设计规范色值，仅凭肉眼极易误判。</p>
        <p>iScreenshot 在截屏流程中原生深度整合了高速视网膜放大镜取色器，让像素核验与调色取样如同显微镜般清晰可见。</p>
      </div>

      <div class="card">
        <div class="card-header">
          <span class="card-title">放大镜与取色器核心特性</span>
          <span class="term-pill mono">4x 视网膜网格 + 实时色值</span>
        </div>
        <div class="prose">
          <ul style="padding-left: 20px; line-height: 1.8;">
            <li><strong>4 倍高倍率物理像素网格</strong>：清晰划分视网膜像素栅格，中心配备醒目十字准星，落点分毫不差。</li>
            <li><strong>双格式实时色值呈现</strong>：同步显示标准十六进制 Hex 色值（如 <code>#3B82F6</code>）与标准 RGB 数值。</li>
            <li><strong>'C' 键一键闪电复制</strong>：鼠标悬停在任意像素上，只需轻按键盘 <kbd class="kbd">C</kbd> 键，色值代码瞬间拷入剪贴板，无需完成截图。</li>
            <li><strong>亚像素坐标与尺寸抬头显示</strong>：实时展示当前光标在屏幕上的绝对 X/Y 坐标，标注调优心中有数。</li>
          </ul>
        </div>
      </div>
    </section>

    <section class="content-section">
      <h2 class="section-heading">多屏色彩管理与方向键微调</h2>
      <div class="prose">
        <p>放大镜完美支持外接 4K/5K 专业显示器及 Display P3 / sRGB 广色域色彩空间，避免色彩偏移失真。配合键盘方向键，支持 1 像素为步进的极微调整，助力像素级还原设计稿。</p>
      </div>
    </section>
""",
        "faq_en": [
            {
                "q": "How do I copy a color code without creating a screenshot file?",
                "a": "Simply press ⌃A to activate capture mode, hover over your desired pixel, and press 'C'. The Hex code is immediately copied to your clipboard, and you can press Esc to dismiss."
            },
            {
                "q": "Does the magnifier work across multi-monitor setups?",
                "a": "Yes. It seamlessly transitions across built-in MacBook screens and external 4K/5K monitors with full DPI and color profile awareness."
            }
        ],
        "faq_zh": [
            {
                "q": "如何只取色而不生成任何截图文件？",
                "a": "按下 ⌃A 进入截图模式，光标移动到目标位置，直接按下键盘上的 'C' 键，Hex 颜色代码即已拷入剪贴板；随后按 Esc 键即可退出，干净利落。"
            },
            {
                "q": "放大镜支持外接双屏或扩展显示器吗？",
                "a": "完全支持。放大镜能够在 MacBook 内置屏与外接 4K/5K 显示器之间丝滑穿梭，自动匹配各屏幕的原生分辨率与色域。"
            }
        ]
    },

    # ── 5. CleanShot X Alternative ─────────────────────────────────────────────
    {
        "slug": "download/cleanshot-alternative",
        "tag_en": "FREE CLEANSHOT X ALTERNATIVE",
        "tag_zh": "免费 CLEANSHOT X / SHOTTR 替代品",
        "title_en": "Best Free CleanShot X Alternative for Mac – Open Source & Native | iScreenshot",
        "title_zh": "最佳免费 CleanShot X / Shottr 替代品 - 原生开源无订阅｜极速截屏",
        "meta_en": "Looking for a free alternative to CleanShot X or Shottr? iScreenshot is 100% open-source (MIT), native Swift 6, offline-first, with scrolling screenshot, internal audio recording, and mockup studio.",
        "meta_zh": "寻找 CleanShot X 或 Shottr 的免费替代品？iScreenshot（极速截屏）完全免费开源 (MIT)，原生 Swift 6 极速秒开，支持滚动长截图、免声卡驱动系统声音录屏与样机美化，零隐私回传。",
        "h1_en": "The Modern, Open-Source Alternative to CleanShot X & Shottr",
        "h1_zh": "告别订阅与闭源：新一代开源原生 Mac 截屏利器",
        "lead_en": "Get all the power of professional Mac screenshot software without recurring subscriptions, proprietary cloud locks, or bloated Electron runtimes. Fast, lightweight, and 100% free under the MIT license.",
        "lead_zh": "无需支付高昂买断费或每年续费订阅，拒绝云端隐私风险与臃肿跨平台架构。纯原生 Swift 6 编写，集全能标注、滚动长图、系统内录、美化样机与屏幕贴图于一身，开源透明。",
        "bc_en": [("Download", f"{BASE_URL}/#download"), ("CleanShot X Alternative", "")],
        "bc_zh": [("下载", f"{BASE_URL}/zh.html#download"), ("CleanShot 替代品", "")],
        "cta_title_en": "Switch to iScreenshot for Mac today",
        "cta_title_zh": "立即下载轻盈自由的 iScreenshot",
        "cta_desc_en": "Free, MIT open-source, and natively optimized for Apple Silicon and macOS 14+.",
        "cta_desc_zh": "完全免费、MIT 开源授权，原生针对 Apple 芯片与 macOS 14+ 深度优化。",
        "sections_en": """
    <section class="content-section">
      <h2 class="section-heading">Why Pay $29 + $19/Year for a Screenshot Utility?</h2>
      <div class="prose">
        <p>CleanShot X is undoubtedly a capable Mac application, but its pricing has grown increasingly hostile to individual creators, students, and budget-conscious teams. Users face a $29 upfront price tag plus mandatory $19/year renewal fees to receive updates. Alternative tools like Shottr charge $12 per device, while cloud services upload your confidential screenshots to third-party databases.</p>
        <p><strong>iScreenshot (极速截屏)</strong> was created with a clear mission: deliver a studio-grade, native screenshot and screen recording application that is 100% free, forever open-source under the MIT license, and respects your privacy completely.</p>
      </div>

      <div class="card">
        <div class="card-header">
          <span class="card-title">Comprehensive Feature Comparison</span>
          <span class="term-pill mono">iScreenshot vs CleanShot X vs Shottr</span>
        </div>
        <div class="data-table-wrapper">
          <table class="data-table">
            <thead>
              <tr>
                <th>Feature / Metric</th>
                <th style="color: var(--accent); font-weight: 700;">iScreenshot</th>
                <th>CleanShot X</th>
                <th>Shottr</th>
                <th>macOS Native</th>
              </tr>
            </thead>
            <tbody>
              <tr>
                <td><strong>Pricing</strong></td>
                <td><strong style="color: var(--signal-success);">$0 (100% Free)</strong></td>
                <td>$29 + $19/yr renewal</td>
                <td>$12 / device</td>
                <td>Free with macOS</td>
              </tr>
              <tr>
                <td><strong>Source Code</strong></td>
                <td><span class="term-pill">MIT Open Source</span></td>
                <td>Proprietary closed</td>
                <td>Proprietary closed</td>
                <td>Closed Source</td>
              </tr>
              <tr>
                <td><strong>Scrolling Screenshot</strong></td>
                <td>Auto + Manual Stitching</td>
                <td>Included</td>
                <td>Included</td>
                <td>Not Supported</td>
              </tr>
              <tr>
                <td><strong>Mockup Studio</strong></td>
                <td>Native macOS / Browser</td>
                <td>Basic backgrounds</td>
                <td>Not Included</td>
                <td>Not Supported</td>
              </tr>
              <tr>
                <td><strong>Internal Audio Recording</strong></td>
                <td>Native ScreenCaptureKit</td>
                <td>Driver Required</td>
                <td>No Recording</td>
                <td>Not Supported</td>
              </tr>
              <tr>
                <td><strong>Privacy / Telemetry</strong></td>
                <td>100% Offline, Zero Tracking</td>
                <td>Cloud accounts / tracking</td>
                <td>Closed telemetry</td>
                <td>System diagnostics</td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </section>

    <section class="content-section">
      <h2 class="section-heading">Seamless 3-Step Migration</h2>
      <div class="step-list">
        <div class="step-item">
          <div class="step-num">1</div>
          <div class="step-content">
            <h4>Download DMG</h4>
            <p>Grab the latest verified universal DMG release from <a href="https://github.com/cduyzh/iScreenshot/releases" target="_blank" rel="noopener" style="color: var(--accent); text-decoration: underline;">GitHub Releases</a> and drag it into your Applications folder.</p>
          </div>
        </div>
        <div class="step-item">
          <div class="step-num">2</div>
          <div class="step-content">
            <h4>Grant Standard Permissions</h4>
            <p>Grant macOS <strong>Screen Recording</strong> in System Settings. Optionally enable <strong>Accessibility</strong> for automated scroll capture.</p>
          </div>
        </div>
        <div class="step-item">
          <div class="step-num">3</div>
          <div class="step-content">
            <h4>Bind Your Familiar Shortcuts</h4>
            <p>Keep your muscle memory intact: iScreenshot defaults to <kbd class="kbd">⌃A</kbd> for capture, <kbd class="kbd">⌥S</kbd> for long scrolling screenshots, and <kbd class="kbd">⌥E</kbd> for image beautification.</p>
          </div>
        </div>
      </div>
    </section>
""",
        "sections_zh": """
    <section class="content-section">
      <h2 class="section-heading">为什么截屏工具不应该成为昂贵的续费负担？</h2>
      <div class="prose">
        <p>CleanShot X 确实功能丰富，但其商业模式逐渐让许多个人开发者、学生和团队望而却步：29 美元买断价外加每年 19 美元订阅更新费；Shottr 则按设备授权 12 美元。更重要的是，许多商业截屏软件绑定了强制云端同步与分析追踪，私密截图面临潜在泄露风险。</p>
        <p><strong>iScreenshot（极速截屏）</strong> 为此而生：打造一款真正媲美甚至超越商业截屏体验的原生工具，坚持 100% 完全免费、MIT 协议开源透明，绝不上云，绝无广告弹窗与内购限制。</p>
      </div>

      <div class="card">
        <div class="card-header">
          <span class="card-title">深度横向参数横评</span>
          <span class="term-pill mono">iScreenshot vs CleanShot X vs Shottr</span>
        </div>
        <div class="data-table-wrapper">
          <table class="data-table">
            <thead>
              <tr>
                <th>核心功能与参数</th>
                <th style="color: var(--accent); font-weight: 700;">iScreenshot</th>
                <th>CleanShot X</th>
                <th>Shottr</th>
                <th>macOS 系统自带</th>
              </tr>
            </thead>
            <tbody>
              <tr>
                <td><strong>收费模式</strong></td>
                <td><strong style="color: var(--signal-success);">完全免费 ($0)</strong></td>
                <td>$29 + $19/年 续费</td>
                <td>$12 / 台设备</td>
                <td>免费 (系统内置)</td>
              </tr>
              <tr>
                <td><strong>开源授权</strong></td>
                <td><span class="term-pill">MIT 开源透明</span></td>
                <td>商业闭源</td>
                <td>商业闭源</td>
                <td>闭源系统组件</td>
              </tr>
              <tr>
                <td><strong>滚动长截图</strong></td>
                <td>支持 (自动+手动双模式)</td>
                <td>支持</td>
                <td>支持</td>
                <td>不支持</td>
              </tr>
              <tr>
                <td><strong>图片美化与样机外壳</strong></td>
                <td>内置 5 种视窗样机+渐变</td>
                <td>基础背景填充</td>
                <td>不支持</td>
                <td>不支持</td>
              </tr>
              <tr>
                <td><strong>系统声音内录录屏</strong></td>
                <td>免驱动原生内录</td>
                <td>需装额外音频驱动</td>
                <td>无录屏功能</td>
                <td>不支持系统声音</td>
              </tr>
              <tr>
                <td><strong>数据与隐私</strong></td>
                <td>100% 本地离线，零追踪</td>
                <td>云端存储/账户依赖</td>
                <td>闭源追踪</td>
                <td>系统级收集</td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </section>

    <section class="content-section">
      <h2 class="section-heading">轻松三步无痛迁移</h2>
      <div class="step-list">
        <div class="step-item">
          <div class="step-num">1</div>
          <div class="step-content">
            <h4>下载并拖入应用目录</h4>
            <p>从 <a href="https://github.com/cduyzh/iScreenshot/releases" target="_blank" rel="noopener" style="color: var(--accent); text-decoration: underline;">GitHub Releases</a> 获取最新官方 DMG 安装包，拖入“应用程序”文件夹即完成安装。</p>
          </div>
        </div>
        <div class="step-item">
          <div class="step-num">2</div>
          <div class="step-content">
            <h4>授予标准必要权限</h4>
            <p>在系统设置中授予“屏幕录制”权限；如需使用长截图自动滚屏，可自选开启“辅助功能”权限。</p>
          </div>
        </div>
        <div class="step-item">
          <div class="step-num">3</div>
          <div class="step-content">
            <h4>无缝衔接肌肉记忆</h4>
            <p>iScreenshot 默认全局快捷键：<kbd class="kbd">⌃A</kbd> 区域截屏、<kbd class="kbd">⌥S</kbd> 滚动长截图、<kbd class="kbd">⌥E</kbd> 美化工作室、<kbd class="kbd">⌥P</kbd> 屏幕贴图，按键习惯无需痛苦重构。</p>
          </div>
        </div>
      </div>
    </section>
""",
        "faq_en": [
            {
                "q": "Is iScreenshot really completely free?",
                "a": "Yes, absolutely. iScreenshot is published under the permissive MIT Open Source License. There are no subscriptions, no in-app purchases, no pro tier limits, and no advertising."
            },
            {
                "q": "Can I replace CleanShot X's default shortcuts with iScreenshot?",
                "a": "Yes. iScreenshot allows fully customizable global shortcuts in Settings, so you can map whichever keys match your muscle memory."
            },
            {
                "q": "Does it receive regular updates?",
                "a": "Yes. The app includes a built-in native update checker connected directly to official GitHub Releases. You can inspect full release notes and update with a single click."
            }
        ],
        "faq_zh": [
            {
                "q": "iScreenshot 真的完全免费没有任何内购吗？",
                "a": "是的。iScreenshot 采用宽松的 MIT 开源协议发布，没有任何订阅费用、内购限制、设备数量上限或付费 Pro 版区分，所有功能开箱即用。"
            },
            {
                "q": "可以无缝替换我之前的 CleanShot X 快捷键吗？",
                "a": "可以。iScreenshot 在偏好设置中提供了灵活的全局快捷键配置，您可以自由绑定习惯的按键组合。"
            },
            {
                "q": "以后会有持续更新维护吗？",
                "a": "项目由作者持续维护，应用内自带原生更新检查器，直连 GitHub Releases 官方接口，有新版本时会弹出更新日志并支持一键升级。"
            }
        ]
    }
]

# ── Generate All Feature Landing Pages ────────────────────────────────────────
print("Generating 5 feature pairs (10 landing pages)...")
for page in pages_data:
    slug = page["slug"]
    
    # English Page
    en_html = generate_page(
        lang="en",
        slug=slug,
        title=page["title_en"],
        meta_desc=page["meta_en"],
        h1=page["h1_en"],
        lead=page["lead_en"],
        tag=page["tag_en"],
        breadcrumb_items=page["bc_en"],
        sections_html=page["sections_en"],
        faq_list=page["faq_en"],
        cta_title=page["cta_title_en"],
        cta_desc=page["cta_desc_en"]
    )
    en_dir = os.path.join(OUTPUT_DIR, slug)
    os.makedirs(en_dir, exist_ok=True)
    en_file = os.path.join(en_dir, "index.html")
    with open(en_file, "w", encoding="utf-8") as f:
        f.write(en_html)
    print(f"  Generated: {en_file}")

    # Chinese Page
    zh_html = generate_page(
        lang="zh-CN",
        slug=slug,
        title=page["title_zh"],
        meta_desc=page["meta_zh"],
        h1=page["h1_zh"],
        lead=page["lead_zh"],
        tag=page["tag_zh"],
        breadcrumb_items=page["bc_zh"],
        sections_html=page["sections_zh"],
        faq_list=page["faq_zh"],
        cta_title=page["cta_title_zh"],
        cta_desc=page["cta_desc_zh"]
    )
    zh_dir = os.path.join(OUTPUT_DIR, "zh", slug)
    os.makedirs(zh_dir, exist_ok=True)
    zh_file = os.path.join(zh_dir, "index.html")
    with open(zh_file, "w", encoding="utf-8") as f:
        f.write(zh_html)
    print(f"  Generated: {zh_file}")

print("All 10 landing pages generated successfully!")

# ── Generate website/index.html (Quiet Native English Homepage) ───────────────
index_html = f"""<!doctype html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>iScreenshot – Native macOS Screenshot, Scrolling Capture & Mockup Studio</title>
  <meta name="description" content="iScreenshot is a fast, native macOS screenshot and screen recording app. Intelligent window snapping, sub-pixel scrolling long capture, mockup studio with window frames, and internal audio recording. 100% free & open-source." />
  <meta name="keywords" content="iScreenshot, snapscreen, mac screenshot tool, scrolling screenshot mac, mac screen recorder system audio, cleanshot alternative, screenshot mockup studio, retina color picker mac" />
  <link rel="canonical" href="{BASE_URL}/" />
  <link rel="alternate" hreflang="en" href="{BASE_URL}/" />
  <link rel="alternate" hreflang="zh-CN" href="{BASE_URL}/zh.html" />
  <link rel="alternate" hreflang="x-default" href="{BASE_URL}/" />

  <meta property="og:type" content="website" />
  <meta property="og:site_name" content="iScreenshot" />
  <meta property="og:title" content="iScreenshot – Native macOS Screenshot, Scrolling Capture & Mockup Studio" />
  <meta property="og:description" content="Fast, native macOS menu-bar screenshot tool. Region capture, sub-pixel scrolling long screenshot, window frames & gradient studio, and driver-free system sound recording." />
  <meta property="og:url" content="{BASE_URL}/" />
  <meta property="og:image" content="{BASE_URL}/assets/app-icon.png" />
  <meta name="twitter:card" content="summary_large_image" />
  <meta name="twitter:title" content="iScreenshot – Native macOS Screenshot Tool" />
  <meta name="twitter:description" content="Fast, native macOS screenshot & screen recorder with system audio. MIT Open Source." />
  <meta name="twitter:image" content="{BASE_URL}/assets/app-icon.png" />

  <script type="application/ld+json">
  {{
    "@context": "https://schema.org",
    "@graph": [
      {{
        "@type": "WebSite",
        "@id": "{BASE_URL}/#website",
        "url": "{BASE_URL}/",
        "name": "iScreenshot",
        "description": "Fast native macOS screenshot and screen recording application",
        "inLanguage": "en",
        "publisher": {{
          "@id": "https://www.cduyzh.top/#cduyzh"
        }}
      }},
      {{
        "@type": "WebPage",
        "@id": "{BASE_URL}/#webpage",
        "url": "{BASE_URL}/",
        "name": "iScreenshot – Native macOS Screenshot, Scrolling Capture & Mockup Studio",
        "description": "Fast native macOS menu-bar screenshot tool with window snapping, scrolling capture, mockup studio, and screen recording with system audio.",
        "isPartOf": {{
          "@id": "{BASE_URL}/#website"
        }},
        "inLanguage": "en",
        "mainEntity": {{
          "@id": "{BASE_URL}/#software"
        }}
      }},
      {{
        "@type": "Person",
        "@id": "https://www.cduyzh.top/#cduyzh",
        "name": "cduyzh",
        "url": "https://www.cduyzh.top",
        "sameAs": "https://github.com/cduyzh"
      }},
      {{
        "@type": "SoftwareApplication",
        "@id": "{BASE_URL}/#software",
        "name": "iScreenshot",
        "alternateName": ["SnapScreen", "极速截屏"],
        "operatingSystem": "macOS 14.0 or later",
        "applicationCategory": "UtilitiesApplication",
        "applicationSubCategory": "Productivity",
        "memoryRequirements": "35MB",
        "description": "Native macOS menu-bar app for screenshots, scrolling long captures, image beautification studio with window frames, and screen recording with system audio.",
        "softwareVersion": "1.0.0",
        "url": "{BASE_URL}/",
        "sameAs": "{REPO_URL}",
        "downloadUrl": "{REPO_URL}/releases",
        "isAccessibleForFree": true,
        "author": {{
          "@id": "https://www.cduyzh.top/#cduyzh"
        }},
        "license": "https://opensource.org/licenses/MIT",
        "featureList": [
          "Smart window boundary snapping via CGWindowListCopyWindowInfo",
          "4x Retina pixel grid magnifier and instantaneous Hex/RGB color picker",
          "Scrolling long screenshot with sub-pixel RGB feature stitching",
          "Screenshot Studio with macOS light/dark frames and modern browser chrome",
          "Screen recording with 48kHz system audio via Apple ScreenCaptureKit (zero drivers)",
          "Always-on-top desktop image pinning with zoom and transparency controls"
        ],
        "offers": {{
          "@type": "Offer",
          "price": "0",
          "priceCurrency": "USD"
        }}
      }},
      {{
        "@type": "FAQPage",
        "@id": "{BASE_URL}/#faq",
        "mainEntity": [
          {{
            "@type": "Question",
            "name": "What is iScreenshot?",
            "acceptedAnswer": {{
              "@type": "Answer",
              "text": "iScreenshot (formerly SnapScreen) is an open-source, native macOS screenshot and screen recording utility built with Swift 6, AppKit, SwiftUI, and ScreenCaptureKit. It operates completely offline with zero telemetry."
            }}
          }},
          {{
            "@type": "Question",
            "name": "Is iScreenshot completely free?",
            "acceptedAnswer": {{
              "@type": "Answer",
              "text": "Yes. iScreenshot is 100% free and open-source under the MIT license with no subscriptions, no ads, and no locked features."
            }}
          }},
          {{
            "@type": "Question",
            "name": "Can it record internal Mac audio without installing extra drivers?",
            "acceptedAnswer": {{
              "@type": "Answer",
              "text": "Yes. Built directly on Apple's ScreenCaptureKit with capturesAudio enabled, iScreenshot records internal system audio at 48kHz stereo without Soundflower or BlackHole."
            }}
          }},
          {{
            "@type": "Question",
            "name": "How does scrolling long capture work?",
            "acceptedAnswer": {{
              "@type": "Answer",
              "text": "Press Option+S to begin. Scroll manually or click Capture Down. High-frequency RGB feature matching stitches continuous frames while filtering duplicate headers and footers."
            }}
          }}
        ]
      }}
    ]
  }}
  </script>

  <style>
{COMMON_CSS}
  .hero-section {{
    text-align: center;
    padding: 60px 24px 48px;
    max-width: 860px;
    margin: 0 auto;
  }}
  .feature-grid {{
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
    gap: 20px;
    margin-top: 32px;
  }}
  .feature-card {{
    background: var(--bg-surface);
    border: var(--border-subtle);
    border-radius: var(--radius-lg);
    padding: 24px;
    box-shadow: var(--shadow-subtle);
    display: flex;
    flex-direction: column;
    justify-content: space-between;
    transition: transform 0.15s ease, box-shadow 0.15s ease;
  }}
  .feature-card:hover {{
    transform: translateY(-2px);
    box-shadow: var(--shadow-card);
  }}
  .feature-icon {{
    font-size: 28px;
    margin-bottom: 12px;
    display: inline-block;
  }}
  .feature-title {{
    font-size: 17px;
    font-weight: 700;
    color: var(--text-primary);
    margin-bottom: 8px;
  }}
  .feature-desc {{
    font-size: 14px;
    color: var(--text-secondary);
    line-height: 1.6;
    margin-bottom: 16px;
    flex-grow: 1;
  }}
  .feature-link {{
    font-size: 13.5px;
    font-weight: 600;
    color: var(--accent);
    display: inline-flex;
    align-items: center;
    gap: 4px;
  }}
  .feature-link:hover {{
    text-decoration: underline;
  }}
  .preview-box {{
    background: var(--bg-surface);
    border: var(--border-subtle);
    border-radius: var(--radius-xl);
    padding: 28px;
    margin: 40px auto;
    box-shadow: var(--shadow-float);
    max-width: 840px;
  }}
  </style>
</head>
<body>
  <!-- Nav -->
  <header class="site-nav">
    <div class="nav-container">
      <a href="{BASE_URL}/" class="brand-group">
        <img class="brand-icon" src="assets/app-icon.png" alt="iScreenshot App Icon" width="32" height="32" />
        <div class="brand-name">iScreenshot <span class="brand-sub">Fast Native Screenshot</span></div>
      </a>
      <nav class="nav-links">
        <a href="#features" class="nav-link">Features</a>
        <a href="{BASE_URL}/download/cleanshot-alternative/" class="nav-link">Download</a>
        <a href="{REPO_URL}" class="nav-link" target="_blank" rel="noopener">GitHub</a>
      </nav>
      <div class="nav-actions">
        <div class="lang-switch">
          <a href="{BASE_URL}/" class="lang-link active">EN</a>
          <span class="lang-sep">/</span>
          <a href="{BASE_URL}/zh.html" class="lang-link">中</a>
        </div>
        <a href="{REPO_URL}" class="btn btn-secondary mono" target="_blank" rel="noopener">GitHub</a>
        <a href="{REPO_URL}/releases" class="btn btn-primary">Download Free</a>
      </div>
    </div>
  </header>

  <!-- Hero -->
  <header class="hero-section">
    <div class="page-tag mono">v1.0.0 · macOS 14.0+ · Apple Silicon & Intel</div>
    <h1 class="page-title" style="font-size: clamp(32px, 4.5vw, 48px); margin-bottom: 16px;">
      The Fastest Native Screenshot & Recording Studio for Mac
    </h1>
    <p class="page-lead" style="margin: 0 auto 28px;">
      Lightweight menu-bar tool built with Swift 6 and ScreenCaptureKit. Region capture with window snapping, scrolling long screenshots, window mockups, and driver-free system sound recording. 100% free and open-source.
    </p>
    <div class="cta-buttons">
      <a href="{REPO_URL}/releases" class="btn btn-primary" style="padding: 11px 26px; font-size: 15.5px;">
        Download for macOS
      </a>
      <a href="{BASE_URL}/download/cleanshot-alternative/" class="btn btn-secondary" style="padding: 11px 22px; font-size: 15.5px;">
        CleanShot X Comparison
      </a>
    </div>
    <p style="margin-top: 14px; font-size: 13px; color: var(--text-tertiary);">
      Zero closed-source dependencies · 100% Offline Privacy · MIT License
    </p>
  </header>

  <!-- Main Container -->
  <main class="page-container" style="padding-top: 0;">
    <!-- Core Feature Grid -->
    <section class="content-section" id="features">
      <h2 class="section-heading" style="text-align: center; margin-bottom: 8px;">Built for Mac Power Users</h2>
      <p style="text-align: center; color: var(--text-secondary); margin-bottom: 32px; font-size: 15px;">
        Everything you need to capture, annotate, polish, and record — all in one native menu bar app.
      </p>

      <div class="feature-grid">
        <!-- 1. Scrolling Screenshot -->
        <article class="feature-card">
          <div>
            <div class="feature-icon">📜</div>
            <h3 class="feature-title">Scrolling Long Screenshot</h3>
            <p class="feature-desc">
              Capture full web pages, source code files, and chat logs. Multi-row RGB feature stitching with automatic header/footer deduplication and seam recovery.
            </p>
          </div>
          <a href="{BASE_URL}/features/scrolling-capture/" class="feature-link">Explore Scrolling Capture →</a>
        </article>

        <!-- 2. Screenshot Studio -->
        <article class="feature-card">
          <div>
            <div class="feature-icon">🎨</div>
            <h3 class="feature-title">Mockup Studio & Frames</h3>
            <p class="feature-desc">
              Turn raw screenshots into publication-ready graphics. macOS light/dark frames, browser chrome, content-aware Gaussian blur, and squircle corners.
            </p>
          </div>
          <a href="{BASE_URL}/features/screenshot-studio/" class="feature-link">Explore Mockup Studio →</a>
        </article>

        <!-- 3. Screen Recorder -->
        <article class="feature-card">
          <div>
            <div class="feature-icon">🎥</div>
            <h3 class="feature-title">Screen Recorder with System Audio</h3>
            <p class="feature-desc">
              Record custom regions at 60 FPS with internal audio via Apple ScreenCaptureKit. No Soundflower, no BlackHole, and zero driver installation.
            </p>
          </div>
          <a href="{BASE_URL}/features/screen-recorder/" class="feature-link">Explore Screen Recording →</a>
        </article>

        <!-- 4. Magnifier & Color Picker -->
        <article class="feature-card">
          <div>
            <div class="feature-icon">🔍</div>
            <h3 class="feature-title">Retina Pixel Color Picker</h3>
            <p class="feature-desc">
              4x Retina magnification grid with center crosshairs and live RGB Hex codes. Press 'C' to copy color values instantly on any display.
            </p>
          </div>
          <a href="{BASE_URL}/features/pixel-color-picker/" class="feature-link">Explore Color Picker →</a>
        </article>

        <!-- 5. Smart Region Snapping -->
        <article class="feature-card">
          <div>
            <div class="feature-icon">📸</div>
            <h3 class="feature-title">Smart Window Snapping</h3>
            <p class="feature-desc">
              Hover to detect window boundaries automatically with Option-key shadow toggle. Drag freely for custom rectangular regions.
            </p>
          </div>
          <span class="mono" style="font-size: 12.5px; color: var(--text-tertiary);">Hotkey: ⌃A</span>
        </article>

        <!-- 6. Desktop Pinning -->
        <article class="feature-card">
          <div>
            <div class="feature-icon">📌</div>
            <h3 class="feature-title">Always-On-Top Pinning</h3>
            <p class="feature-desc">
              Float screenshots above all windows for reference. Move freely, zoom with mouse scroll, or adjust opacity with a right-click.
            </p>
          </div>
          <span class="mono" style="font-size: 12.5px; color: var(--text-tertiary);">Hotkey: ⌥P</span>
        </article>
      </div>
    </section>

    <!-- Keyboard Shortcuts Overview Table -->
    <section class="content-section">
      <h2 class="section-heading">Keyboard Shortcuts at a Glance</h2>
      <div class="card" style="padding: 0; overflow: hidden;">
        <table class="data-table">
          <thead>
            <tr>
              <th>Action</th>
              <th>Shortcut</th>
              <th>Workflow Notes</th>
            </tr>
          </thead>
          <tbody>
            <tr>
              <td><strong>Region Screenshot</strong></td>
              <td><kbd class="kbd">⌃A</kbd></td>
              <td>Window snapping or free drag selection</td>
            </tr>
            <tr>
              <td><strong>Scrolling Long Screenshot</strong></td>
              <td><kbd class="kbd">⌥S</kbd></td>
              <td>Auto or manual scroll stitching</td>
            </tr>
            <tr>
              <td><strong>Image Beautification Studio</strong></td>
              <td><kbd class="kbd">⌥E</kbd></td>
              <td>Load from clipboard or disk file; press <kbd class="kbd">E</kbd> during selection</td>
            </tr>
            <tr>
              <td><strong>Screen Recording</strong></td>
              <td><kbd class="kbd">⌃[</kbd></td>
              <td>With system audio; press again to finish</td>
            </tr>
            <tr>
              <td><strong>Pin to Desktop</strong></td>
              <td><kbd class="kbd">⌥P</kbd></td>
              <td>Always-on-top floating reference window</td>
            </tr>
            <tr>
              <td><strong>Instant Copy & Finish</strong></td>
              <td><kbd class="kbd">Enter</kbd> / Double Click</td>
              <td>Copies composite result straight to clipboard</td>
            </tr>
          </tbody>
        </table>
      </div>
    </section>

    <!-- FAQ -->
    <section class="content-section">
      <h2 class="section-heading">Frequently Asked Questions</h2>
      <details class="faq-item">
        <summary class="faq-summary">Is iScreenshot free and open source?</summary>
        <div class="faq-content">
          <p>Yes. iScreenshot is licensed under the MIT License. It is completely free to download, inspect, build, and use. There are zero subscriptions, paywalls, or advertising.</p>
        </div>
      </details>
      <details class="faq-item">
        <summary class="faq-summary">Which macOS versions are supported?</summary>
        <div class="faq-content">
          <p>iScreenshot supports macOS 14.0 Sonoma, macOS 15+ Sequoia, and newer, on both Apple Silicon (M1/M2/M3/M4) and Intel Macs.</p>
        </div>
      </details>
      <details class="faq-item">
        <summary class="faq-summary">How does it record computer sound without virtual audio cables?</summary>
        <div class="faq-content">
          <p>It utilizes Apple's native ScreenCaptureKit framework introduced in recent macOS versions with <code>capturesAudio = true</code>. This taps directly into the macOS audio rendering pipeline at 48kHz stereo without needing kernel extensions or BlackHole drivers.</p>
        </div>
      </details>
      <details class="faq-item">
        <summary class="faq-summary">Where are screenshots and recordings stored?</summary>
        <div class="faq-content">
          <p>By default, pressing Enter copies captures directly to your clipboard to keep your disk clean. Pressing Cmd+S or finishing a screen recording saves the file directly into your <code>~/Downloads</code> folder and delivers a notification offering one-click access in Finder.</p>
        </div>
      </details>
    </section>

    <!-- Bottom CTA -->
    <div class="cta-box">
      <h3 class="cta-title">Upgrade Your Mac Screenshot Experience</h3>
      <p class="cta-desc">Download iScreenshot today and enjoy blazing-fast capture, beautiful mockups, and seamless internal audio recording.</p>
      <div class="cta-buttons">
        <a href="{REPO_URL}/releases" class="btn btn-primary" style="padding: 10px 24px; font-size: 15px;">
          Download for Mac (v1.0.0)
        </a>
        <a href="{BASE_URL}/download/cleanshot-alternative/" class="btn btn-secondary" style="padding: 10px 20px; font-size: 15px;">
          CleanShot X Alternative
        </a>
      </div>
    </div>
  </main>

  <!-- Footer -->
  <footer>
    <div class="footer-container">
      <span>© 2026 cduyzh · iScreenshot · All rights reserved.</span>
      <div class="footer-links">
        <a href="https://www.cduyzh.top" target="_blank" rel="noopener">cduyzh.top</a>
        <a href="https://www.cduyzh.top/goal" target="_blank" rel="noopener">Goal</a>
        <a href="{REPO_URL}" target="_blank" rel="noopener">GitHub</a>
        <a href="https://opensource.org/licenses/MIT" target="_blank" rel="noopener">MIT License</a>
      </div>
    </div>
  </footer>
</body>
</html>
"""

with open(os.path.join(OUTPUT_DIR, "index.html"), "w", encoding="utf-8") as f:
    f.write(index_html)
print(f"Generated: {os.path.join(OUTPUT_DIR, 'index.html')}")

# ── Generate website/zh.html (Quiet Native Chinese Homepage) ──────────────────
zh_home_html = f"""<!doctype html>
<html lang="zh-CN">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>iScreenshot 极速截屏 – 原生轻量 Mac 截图、滚动长截图、样机美化与内录录屏</title>
  <meta name="description" content="iScreenshot（极速截屏）是一款现代原生的 macOS 菜单栏截屏利器。智能视窗吸附、多特征对齐滚动长截图、自带设计级样机外框工作室，以及 ScreenCaptureKit 免驱动系统声音录屏。完全免费开源。" />
  <meta name="keywords" content="iScreenshot, 极速截屏, SnapScreen, mac 截图软件, mac 滚动长截图, mac 录屏系统声音免驱动, cleanshot 替代品, shottr 替代, 截图加外壳, mac 取色器" />
  <link rel="canonical" href="{BASE_URL}/zh.html" />
  <link rel="alternate" hreflang="zh-CN" href="{BASE_URL}/zh.html" />
  <link rel="alternate" hreflang="en" href="{BASE_URL}/" />
  <link rel="alternate" hreflang="x-default" href="{BASE_URL}/" />

  <meta property="og:type" content="website" />
  <meta property="og:site_name" content="iScreenshot 极速截屏" />
  <meta property="og:title" content="iScreenshot 极速截屏 – 原生轻量 Mac 截图、滚动长截图与样机工作室" />
  <meta property="og:description" content="原生 Swift 6 打造的 macOS 极速截屏工具。智能窗口吸附、视网膜像素放大镜、长网页拼接、样机外框美化与免装声卡驱动系统声音录屏。" />
  <meta property="og:url" content="{BASE_URL}/zh.html" />
  <meta property="og:image" content="{BASE_URL}/assets/app-icon.png" />
  <meta name="twitter:card" content="summary_large_image" />
  <meta name="twitter:title" content="iScreenshot 极速截屏 – 原生 Mac 截图与录屏利器" />
  <meta name="twitter:description" content="原生轻量 Mac 截图、长图拼接、样机美化与系统内录录屏。MIT 开源免费。" />
  <meta name="twitter:image" content="{BASE_URL}/assets/app-icon.png" />

  <script type="application/ld+json">
  {{
    "@context": "https://schema.org",
    "@graph": [
      {{
        "@type": "WebSite",
        "@id": "{BASE_URL}/#website",
        "url": "{BASE_URL}/",
        "name": "iScreenshot 极速截屏",
        "description": "原生轻量 macOS 截图、长图拼接、样机美化与系统声音录屏工具",
        "inLanguage": "zh-CN",
        "publisher": {{
          "@id": "https://www.cduyzh.top/#cduyzh"
        }}
      }},
      {{
        "@type": "WebPage",
        "@id": "{BASE_URL}/zh.html#webpage",
        "url": "{BASE_URL}/zh.html",
        "name": "iScreenshot 极速截屏 – 原生轻量 Mac 截图、滚动长截图、样机美化与内录录屏",
        "description": "现代原生的 macOS 菜单栏截屏利器。智能视窗吸附、多特征对齐滚动长截图、自带设计级样机外框工作室，以及 ScreenCaptureKit 免驱动系统声音录屏。",
        "isPartOf": {{
          "@id": "{BASE_URL}/#website"
        }},
        "inLanguage": "zh-CN",
        "mainEntity": {{
          "@id": "{BASE_URL}/#software"
        }}
      }},
      {{
        "@type": "Person",
        "@id": "https://www.cduyzh.top/#cduyzh",
        "name": "cduyzh",
        "url": "https://www.cduyzh.top",
        "sameAs": "https://github.com/cduyzh"
      }},
      {{
        "@type": "SoftwareApplication",
        "@id": "{BASE_URL}/#software",
        "name": "iScreenshot",
        "alternateName": ["极速截屏", "SnapScreen"],
        "operatingSystem": "macOS 14.0 或更高版本",
        "applicationCategory": "UtilitiesApplication",
        "applicationSubCategory": "Productivity",
        "memoryRequirements": "35MB",
        "description": "原生 macOS 菜单栏截图、滚动长图拼接、视窗样机美化工作室与免装驱动系统声音录屏工具。",
        "softwareVersion": "1.0.0",
        "url": "{BASE_URL}/zh.html",
        "sameAs": "{REPO_URL}",
        "downloadUrl": "{REPO_URL}/releases",
        "isAccessibleForFree": true,
        "author": {{
          "@id": "https://www.cduyzh.top/#cduyzh"
        }},
        "license": "https://opensource.org/licenses/MIT",
        "featureList": [
          "智能窗口边缘吸附探测（CGWindowListCopyWindowInfo）",
          "4x 视网膜像素放大镜与 Hex/RGB 色值瞬时取色器",
          "基于多行 RGB 特征的亚像素级滚动长截图动态拼接",
          "截图美化工作室（macOS 浅色/深色视窗、现代浏览器外壳、主体智能毛玻璃）",
          "基于 ScreenCaptureKit 的 48kHz 系统声音内录（免装虚拟声卡驱动）",
          "桌面置顶贴图，支持自由缩放、拖拽与透明度调整"
        ],
        "offers": {{
          "@type": "Offer",
          "price": "0",
          "priceCurrency": "CNY"
        }}
      }},
      {{
        "@type": "FAQPage",
        "@id": "{BASE_URL}/zh.html#faq",
        "mainEntity": [
          {{
            "@type": "Question",
            "name": "iScreenshot（极速截屏）是一款怎样的工具？",
            "acceptedAnswer": {{
              "@type": "Answer",
              "text": "iScreenshot（原名 SnapScreen）是一款基于 Swift 6、AppKit、SwiftUI 与 ScreenCaptureKit 纯原生打造的 macOS 菜单栏截图与录屏软件，完全离线运行、零三方闭源依赖、零隐私回传。"
            }}
          }},
          {{
            "@type": "Question",
            "name": "软件是完全免费的吗？有内购或高级版吗？",
            "acceptedAnswer": {{
              "@type": "Answer",
              "text": "软件采用 MIT 开源协议完全免费发布，没有任何订阅费用、内购限制、设备数量上限或付费限制，长截图与录屏所有功能均全量开放。"
            }}
          }},
          {{
            "@type": "Question",
            "name": "录屏真的不需要安装 Soundflower 或 BlackHole 虚拟声卡吗？",
            "acceptedAnswer": {{
              "@type": "Answer",
              "text": "真的不需要。iScreenshot 基于现代 macOS 的 ScreenCaptureKit 原生音频直连通道，直接捕获扬声器渲染总线的声音，无需安装任何额外驱动或内核扩展。"
            }}
          }},
          {{
            "@type": "Question",
            "name": "长截图功能如何使用？",
            "acceptedAnswer": {{
              "@type": "Answer",
              "text": "按 Option+S 唤醒长截图，在目标区域手动滚动或点击“向下自动捕获”，算法通过多行特征对齐自动拼接并剔除吸顶栏，回车一键复制成品大图。"
            }}
          }}
        ]
      }}
    ]
  }}
  </script>

  <style>
{COMMON_CSS}
  .hero-section {{
    text-align: center;
    padding: 60px 24px 48px;
    max-width: 860px;
    margin: 0 auto;
  }}
  .feature-grid {{
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
    gap: 20px;
    margin-top: 32px;
  }}
  .feature-card {{
    background: var(--bg-surface);
    border: var(--border-subtle);
    border-radius: var(--radius-lg);
    padding: 24px;
    box-shadow: var(--shadow-subtle);
    display: flex;
    flex-direction: column;
    justify-content: space-between;
    transition: transform 0.15s ease, box-shadow 0.15s ease;
  }}
  .feature-card:hover {{
    transform: translateY(-2px);
    box-shadow: var(--shadow-card);
  }}
  .feature-icon {{
    font-size: 28px;
    margin-bottom: 12px;
    display: inline-block;
  }}
  .feature-title {{
    font-size: 17px;
    font-weight: 700;
    color: var(--text-primary);
    margin-bottom: 8px;
  }}
  .feature-desc {{
    font-size: 14px;
    color: var(--text-secondary);
    line-height: 1.6;
    margin-bottom: 16px;
    flex-grow: 1;
  }}
  .feature-link {{
    font-size: 13.5px;
    font-weight: 600;
    color: var(--accent);
    display: inline-flex;
    align-items: center;
    gap: 4px;
  }}
  .feature-link:hover {{
    text-decoration: underline;
  }}
  </style>
</head>
<body>
  <!-- Nav -->
  <header class="site-nav">
    <div class="nav-container">
      <a href="{BASE_URL}/zh.html" class="brand-group">
        <img class="brand-icon" src="assets/app-icon.png" alt="iScreenshot 图标" width="32" height="32" />
        <div class="brand-name">iScreenshot <span class="brand-sub">极速截屏</span></div>
      </a>
      <nav class="nav-links">
        <a href="#features" class="nav-link">核心特性</a>
        <a href="{BASE_URL}/zh/download/cleanshot-alternative/" class="nav-link">下载安装</a>
        <a href="{REPO_URL}" class="nav-link" target="_blank" rel="noopener">GitHub</a>
      </nav>
      <div class="nav-actions">
        <div class="lang-switch">
          <a href="{BASE_URL}/" class="lang-link">EN</a>
          <span class="lang-sep">/</span>
          <a href="{BASE_URL}/zh.html" class="lang-link active">中</a>
        </div>
        <a href="{REPO_URL}" class="btn btn-secondary mono" target="_blank" rel="noopener">GitHub</a>
        <a href="{REPO_URL}/releases" class="btn btn-primary">免费下载</a>
      </div>
    </div>
  </header>

  <!-- Hero -->
  <header class="hero-section">
    <div class="page-tag mono">v1.0.0 · macOS 14.0+ · Apple 芯片与 Intel 全适配</div>
    <h1 class="page-title" style="font-size: clamp(30px, 4.2vw, 46px); margin-bottom: 16px;">
      Mac 原生轻量极速截屏、滚动长图与美化工作室
    </h1>
    <p class="page-lead" style="margin: 0 auto 28px;">
      专为 macOS 打造的高性能菜单栏截图利器。智能视窗边缘吸附、多特征对齐长图拼接、精制视窗样机外壳美化，以及免装声卡驱动系统声音内录。100% 免费开源。
    </p>
    <div class="cta-buttons">
      <a href="{REPO_URL}/releases" class="btn btn-primary" style="padding: 11px 26px; font-size: 15.5px;">
        免费下载 Mac 版
      </a>
      <a href="{BASE_URL}/zh/download/cleanshot-alternative/" class="btn btn-secondary" style="padding: 11px 22px; font-size: 15.5px;">
        查看 CleanShot X 深度对比
      </a>
    </div>
    <p style="margin-top: 14px; font-size: 13px; color: var(--text-tertiary);">
      零三方闭源依赖 · 100% 离线隐私保护 · MIT 开源协议
    </p>
  </header>

  <!-- Main Container -->
  <main class="page-container" style="padding-top: 0;">
    <!-- Core Feature Grid -->
    <section class="content-section" id="features">
      <h2 class="section-heading" style="text-align: center; margin-bottom: 8px;">专为高效工作者打造的全能工具箱</h2>
      <p style="text-align: center; color: var(--text-secondary); margin-bottom: 32px; font-size: 15px;">
        将截屏、长图、美化、录屏与贴图无缝收拢于常驻状态栏，极速响应，告别臃肿。
      </p>

      <div class="feature-grid">
        <!-- 1. Scrolling Screenshot -->
        <article class="feature-card">
          <div>
            <div class="feature-icon">📜</div>
            <h3 class="feature-title">智能滚动长截图</h3>
            <p class="feature-desc">
              长网页、长代码与聊天记录一键拼接。多行特征对齐动态滤除重复页眉页尾，支持“帮我接回”防错位恢复。
            </p>
          </div>
          <a href="{BASE_URL}/zh/features/scrolling-capture/" class="feature-link">了解滚动长截图 →</a>
        </article>

        <!-- 2. Screenshot Studio -->
        <article class="feature-card">
          <div>
            <div class="feature-icon">🎨</div>
            <h3 class="feature-title">图片美化与样机工作室</h3>
            <p class="feature-desc">
              截图直出社交画报。macOS 浅深色视窗、现代浏览器外壳、主体智能高斯毛玻璃、超椭圆倒角与弥散阴影。
            </p>
          </div>
          <a href="{BASE_URL}/zh/features/screenshot-studio/" class="feature-link">了解美化工作室 →</a>
        </article>

        <!-- 3. Screen Recorder -->
        <article class="feature-card">
          <div>
            <div class="feature-icon">🎥</div>
            <h3 class="feature-title">高清录屏与系统声音内录</h3>
            <p class="feature-desc">
              ScreenCaptureKit 底层直驱，免装 BlackHole 等虚拟声卡驱动。60 FPS 硬件硬编内录电脑扬声器全部声音。
            </p>
          </div>
          <a href="{BASE_URL}/zh/features/screen-recorder/" class="feature-link">了解系统声音录屏 →</a>
        </article>

        <!-- 4. Magnifier & Color Picker -->
        <article class="feature-card">
          <div>
            <div class="feature-icon">🔍</div>
            <h3 class="feature-title">视网膜像素放大镜与取色</h3>
            <p class="feature-desc">
              4x Retina 物理像素网格、中心十字准星与实时 Hex/RGB 色值。按下 'C' 键秒拷颜色代码进剪贴板。
            </p>
          </div>
          <a href="{BASE_URL}/zh/features/pixel-color-picker/" class="feature-link">了解取色放大镜 →</a>
        </article>

        <!-- 5. Smart Region Snapping -->
        <article class="feature-card">
          <div>
            <div class="feature-icon">📸</div>
            <h3 class="feature-title">智能视窗边缘吸附</h3>
            <p class="feature-desc">
              鼠标悬停自动高亮捕捉视窗边界，按 Option 键快速切换阴影外框，自由拖拽拉框秒选。
            </p>
          </div>
          <span class="mono" style="font-size: 12.5px; color: var(--text-tertiary);">快捷键：⌃A</span>
        </article>

        <!-- 6. Desktop Pinning -->
        <article class="feature-card">
          <div>
            <div class="feature-icon">📌</div>
            <h3 class="feature-title">桌面置顶贴图</h3>
            <p class="feature-desc">
              截图钉在屏幕最上层作为参考比对。滚轮自由无极缩放、右键快捷调节透明度，按 Esc 一键关闭。
            </p>
          </div>
          <span class="mono" style="font-size: 12.5px; color: var(--text-tertiary);">快捷键：⌥P</span>
        </article>
      </div>
    </section>

    <!-- Keyboard Shortcuts Table -->
    <section class="content-section">
      <h2 class="section-heading">常用快捷键速查</h2>
      <div class="card" style="padding: 0; overflow: hidden;">
        <table class="data-table">
          <thead>
            <tr>
              <th>核心功能</th>
              <th>默认快捷键</th>
              <th>操作说明</th>
            </tr>
          </thead>
          <tbody>
            <tr>
              <td><strong>区域截图</strong></td>
              <td><kbd class="kbd">⌃A</kbd></td>
              <td>视窗自动吸附或自由拖拽选区</td>
            </tr>
            <tr>
              <td><strong>滚动长截图</strong></td>
              <td><kbd class="kbd">⌥S</kbd></td>
              <td>手动滚动或辅助功能一键自动滚屏</td>
            </tr>
            <tr>
              <td><strong>图片美化工作室</strong></td>
              <td><kbd class="kbd">⌥E</kbd></td>
              <td>从剪贴板或本地磁盘载入；选区内按 <kbd class="kbd">E</kbd> 直达</td>
            </tr>
            <tr>
              <td><strong>屏幕录制</strong></td>
              <td><kbd class="kbd">⌃[</kbd></td>
              <td>带系统声音内录；再次按下完成保存</td>
            </tr>
            <tr>
              <td><strong>屏幕贴图</strong></td>
              <td><kbd class="kbd">⌥P</kbd></td>
              <td>将截图置顶浮动在所有视窗之上</td>
            </tr>
            <tr>
              <td><strong>完成并复制</strong></td>
              <td><kbd class="kbd">Enter</kbd> / 选区双击</td>
              <td>高清晰度大图瞬间复制进剪贴板</td>
            </tr>
          </tbody>
        </table>
      </div>
    </section>

    <!-- FAQ -->
    <section class="content-section">
      <h2 class="section-heading">常见问题解答 (FAQ)</h2>
      <details class="faq-item">
        <summary class="faq-summary">iScreenshot 是一款完全免费的软件吗？</summary>
        <div class="faq-content">
          <p>是的，软件完全免费且开源。项目采用宽松的 MIT 开源协议，所有功能均无限制开放，绝无广告弹窗、账户登录要求或付费订阅限制。</p>
        </div>
      </details>
      <details class="faq-item">
        <summary class="faq-summary">支持哪些 macOS 系统版本与芯片架构？</summary>
        <div class="faq-content">
          <p>支持 macOS 14.0 Sonoma 及 macOS 15+ Sequoia 或更新版本，原生编译通用二进制包，完美适配 Apple Silicon（M1/M2/M3/M4 系列芯片）以及 Intel 处理器 Mac。</p>
        </div>
      </details>
      <details class="faq-item">
        <summary class="faq-summary">为什么录屏不需要安装虚拟声卡？</summary>
        <div class="faq-content">
          <p>iScreenshot 采用了 Apple 现代 macOS 官方 ScreenCaptureKit 框架，底层支持直接以 48kHz 立体声捕获扬声器渲染总线，彻底消灭了以往依赖 BlackHole / Soundflower 等第三方内核扩展的陈旧做法。</p>
        </div>
      </details>
      <details class="faq-item">
        <summary class="faq-summary">截取的图片保存在哪里？会占用大量磁盘吗？</summary>
        <div class="faq-content">
          <p>默认情况下，按 Enter 完成截图直接写入系统剪贴板，不污染本地磁盘；若按 Cmd+S 手动保存或进行屏幕录制，文件会自动存入本地“下载”文件夹，并推送通知方便一键在访达中定位。</p>
        </div>
      </details>
    </section>

    <!-- Bottom CTA -->
    <div class="cta-box">
      <h3 class="cta-title">立即开启丝滑的 Mac 截屏与录屏体验</h3>
      <p class="cta-desc">告别笨重繁琐的陈旧工具，用原生轻量的方式记录与分享屏幕精彩瞬间。</p>
      <div class="cta-buttons">
        <a href="{REPO_URL}/releases" class="btn btn-primary" style="padding: 10px 24px; font-size: 15px;">
          免费下载 Mac 版 (v1.0.0)
        </a>
        <a href="{BASE_URL}/zh/download/cleanshot-alternative/" class="btn btn-secondary" style="padding: 10px 20px; font-size: 15px;">
          CleanShot 替代横评
        </a>
      </div>
    </div>
  </main>

  <!-- Footer -->
  <footer>
    <div class="footer-container">
      <span>© 2026 cduyzh · iScreenshot · 极速截屏 · 保留所有权利。</span>
      <div class="footer-links">
        <a href="https://www.cduyzh.top" target="_blank" rel="noopener">cduyzh.top</a>
        <a href="https://www.cduyzh.top/goal" target="_blank" rel="noopener">Goal</a>
        <a href="{REPO_URL}" target="_blank" rel="noopener">GitHub</a>
        <a href="https://opensource.org/licenses/MIT" target="_blank" rel="noopener">MIT 授权协议</a>
      </div>
    </div>
  </footer>
</body>
</html>
"""

with open(os.path.join(OUTPUT_DIR, "zh.html"), "w", encoding="utf-8") as f:
    f.write(zh_home_html)
print(f"Generated: {os.path.join(OUTPUT_DIR, 'zh.html')}")

# ── Generate website/robots.txt ──────────────────────────────────────────────
robots_txt = f"""User-agent: *
Allow: /
Sitemap: {BASE_URL}/sitemap.xml
"""
with open(os.path.join(OUTPUT_DIR, "robots.txt"), "w", encoding="utf-8") as f:
    f.write(robots_txt)
print(f"Generated: {os.path.join(OUTPUT_DIR, 'robots.txt')}")

# ── Generate website/sitemap.xml ─────────────────────────────────────────────
sitemap_xml = f"""<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9"
        xmlns:xhtml="http://www.w3.org/1999/xhtml">

  <!-- Homepages -->
  <url>
    <loc>{BASE_URL}/</loc>
    <xhtml:link rel="alternate" hreflang="en" href="{BASE_URL}/"/>
    <xhtml:link rel="alternate" hreflang="zh-CN" href="{BASE_URL}/zh.html"/>
    <xhtml:link rel="alternate" hreflang="x-default" href="{BASE_URL}/"/>
    <changefreq>weekly</changefreq>
    <priority>1.0</priority>
  </url>

  <url>
    <loc>{BASE_URL}/zh.html</loc>
    <xhtml:link rel="alternate" hreflang="zh-CN" href="{BASE_URL}/zh.html"/>
    <xhtml:link rel="alternate" hreflang="en" href="{BASE_URL}/"/>
    <xhtml:link rel="alternate" hreflang="x-default" href="{BASE_URL}/"/>
    <changefreq>weekly</changefreq>
    <priority>1.0</priority>
  </url>

  <!-- Download & CleanShot Alternative -->
  <url>
    <loc>{BASE_URL}/download/cleanshot-alternative/</loc>
    <xhtml:link rel="alternate" hreflang="en" href="{BASE_URL}/download/cleanshot-alternative/"/>
    <xhtml:link rel="alternate" hreflang="zh-CN" href="{BASE_URL}/zh/download/cleanshot-alternative/"/>
    <xhtml:link rel="alternate" hreflang="x-default" href="{BASE_URL}/download/cleanshot-alternative/"/>
    <changefreq>monthly</changefreq>
    <priority>0.9</priority>
  </url>

  <url>
    <loc>{BASE_URL}/zh/download/cleanshot-alternative/</loc>
    <xhtml:link rel="alternate" hreflang="zh-CN" href="{BASE_URL}/zh/download/cleanshot-alternative/"/>
    <xhtml:link rel="alternate" hreflang="en" href="{BASE_URL}/download/cleanshot-alternative/"/>
    <xhtml:link rel="alternate" hreflang="x-default" href="{BASE_URL}/download/cleanshot-alternative/"/>
    <changefreq>monthly</changefreq>
    <priority>0.9</priority>
  </url>

  <!-- Features: Scrolling Long Screenshot -->
  <url>
    <loc>{BASE_URL}/features/scrolling-capture/</loc>
    <xhtml:link rel="alternate" hreflang="en" href="{BASE_URL}/features/scrolling-capture/"/>
    <xhtml:link rel="alternate" hreflang="zh-CN" href="{BASE_URL}/zh/features/scrolling-capture/"/>
    <xhtml:link rel="alternate" hreflang="x-default" href="{BASE_URL}/features/scrolling-capture/"/>
    <changefreq>monthly</changefreq>
    <priority>0.85</priority>
  </url>

  <url>
    <loc>{BASE_URL}/zh/features/scrolling-capture/</loc>
    <xhtml:link rel="alternate" hreflang="zh-CN" href="{BASE_URL}/zh/features/scrolling-capture/"/>
    <xhtml:link rel="alternate" hreflang="en" href="{BASE_URL}/features/scrolling-capture/"/>
    <xhtml:link rel="alternate" hreflang="x-default" href="{BASE_URL}/features/scrolling-capture/"/>
    <changefreq>monthly</changefreq>
    <priority>0.85</priority>
  </url>

  <!-- Features: Screenshot Studio & Mockups -->
  <url>
    <loc>{BASE_URL}/features/screenshot-studio/</loc>
    <xhtml:link rel="alternate" hreflang="en" href="{BASE_URL}/features/screenshot-studio/"/>
    <xhtml:link rel="alternate" hreflang="zh-CN" href="{BASE_URL}/zh/features/screenshot-studio/"/>
    <xhtml:link rel="alternate" hreflang="x-default" href="{BASE_URL}/features/screenshot-studio/"/>
    <changefreq>monthly</changefreq>
    <priority>0.85</priority>
  </url>

  <url>
    <loc>{BASE_URL}/zh/features/screenshot-studio/</loc>
    <xhtml:link rel="alternate" hreflang="zh-CN" href="{BASE_URL}/zh/features/screenshot-studio/"/>
    <xhtml:link rel="alternate" hreflang="en" href="{BASE_URL}/features/screenshot-studio/"/>
    <xhtml:link rel="alternate" hreflang="x-default" href="{BASE_URL}/features/screenshot-studio/"/>
    <changefreq>monthly</changefreq>
    <priority>0.85</priority>
  </url>

  <!-- Features: Screen Recorder with System Audio -->
  <url>
    <loc>{BASE_URL}/features/screen-recorder/</loc>
    <xhtml:link rel="alternate" hreflang="en" href="{BASE_URL}/features/screen-recorder/"/>
    <xhtml:link rel="alternate" hreflang="zh-CN" href="{BASE_URL}/zh/features/screen-recorder/"/>
    <xhtml:link rel="alternate" hreflang="x-default" href="{BASE_URL}/features/screen-recorder/"/>
    <changefreq>monthly</changefreq>
    <priority>0.85</priority>
  </url>

  <url>
    <loc>{BASE_URL}/zh/features/screen-recorder/</loc>
    <xhtml:link rel="alternate" hreflang="zh-CN" href="{BASE_URL}/zh/features/screen-recorder/"/>
    <xhtml:link rel="alternate" hreflang="en" href="{BASE_URL}/features/screen-recorder/"/>
    <xhtml:link rel="alternate" hreflang="x-default" href="{BASE_URL}/features/screen-recorder/"/>
    <changefreq>monthly</changefreq>
    <priority>0.85</priority>
  </url>

  <!-- Features: Retina Pixel Color Picker -->
  <url>
    <loc>{BASE_URL}/features/pixel-color-picker/</loc>
    <xhtml:link rel="alternate" hreflang="en" href="{BASE_URL}/features/pixel-color-picker/"/>
    <xhtml:link rel="alternate" hreflang="zh-CN" href="{BASE_URL}/zh/features/pixel-color-picker/"/>
    <xhtml:link rel="alternate" hreflang="x-default" href="{BASE_URL}/features/pixel-color-picker/"/>
    <changefreq>monthly</changefreq>
    <priority>0.8</priority>
  </url>

  <url>
    <loc>{BASE_URL}/zh/features/pixel-color-picker/</loc>
    <xhtml:link rel="alternate" hreflang="zh-CN" href="{BASE_URL}/zh/features/pixel-color-picker/"/>
    <xhtml:link rel="alternate" hreflang="en" href="{BASE_URL}/features/pixel-color-picker/"/>
    <xhtml:link rel="alternate" hreflang="x-default" href="{BASE_URL}/features/pixel-color-picker/"/>
    <changefreq>monthly</changefreq>
    <priority>0.8</priority>
  </url>

</urlset>
"""
with open(os.path.join(OUTPUT_DIR, "sitemap.xml"), "w", encoding="utf-8") as f:
    f.write(sitemap_xml)
print(f"Generated: {os.path.join(OUTPUT_DIR, 'sitemap.xml')}")

print("\nAll landing pages, homepages, sitemap.xml and robots.txt built and verified successfully!")
