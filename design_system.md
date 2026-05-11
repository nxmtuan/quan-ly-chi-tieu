# Expense Tracker App - Design System

## 1. Typography
**Font Family:** `Plus Jakarta Sans` (Font chữ không chân, bo tròn nhẹ, dễ đọc số liệu).

| Style       | Weight   | Size (px) | Usage                             |
|-------------|----------|-----------|-----------------------------------|
| Heading 1   | Bold     | 32        | Tổng số dư, Tiêu đề màn hình chính|
| Heading 2   | SemiBold | 24        | Tiêu đề Modal, Số tiền giao dịch  |
| Title       | SemiBold | 18        | Tiêu đề Card, Tên danh mục        |
| Body Text   | Medium   | 16        | Text thông thường, Ô nhập liệu    |
| Caption     | Regular  | 14        | Ngày tháng, Ghi chú phụ           |
| Small Tag   | Medium   | 12        | Label, Badge (Tuần/Tháng/Năm)     |

## 2. Color Palette
*Quy tắc: Chỉ dùng màu Solid (màu trơn), không dùng Gradient.*

**Brand / Primary:**
- Primary: `#0D9488` (Xanh teal - Dùng cho nút FAB, Nút lưu)
- Primary Light: `#CCFBF1` (Xanh teal nhạt - Dùng cho background của nút phụ, trạng thái active)

**Semantic (Thu / Chi):**
- Success (Thu): `#10B981` (Xanh ngọc/Mint - Trơn, nổi bật)
- Danger (Chi): `#EF4444` (Đỏ san hô - Trơn, cảnh báo nhưng không chói)
- Warning: `#F59E0B` (Vàng hổ phách)

**Background & Surface (Flat Design):**
- App Background: `#F8FAFC` (Xám ánh xanh cực nhạt, gần như trắng)
- Surface / Cards: `#FFFFFF` (Trắng tinh khiết)

**Text & Icons:**
- Text Primary: `#0F172A` (Đen xám - Đọc lâu không mỏi mắt)
- Text Secondary: `#64748B` (Xám nhạt - Dùng cho phụ đề)
- Borders/Dividers: `#E2E8F0` (Đường kẻ siêu mờ)

### 2.2 Dark Theme Palette 🌙

**Background & Surface (Nền & Thẻ):**
- App Background: `#0F172A` (Xám xanh siêu đậm - Slate 900)
- Surface / Cards: `#1E293B` (Xám xanh sáng hơn một chút để nổi khối - Slate 800)

**Text & Icons (Chữ & Biểu tượng):**
- Text Primary: `#F8FAFC` (Trắng xám nhạt - Dịu mắt khi đọc đêm)
- Text Secondary: `#94A3B8` (Xám trung tính - Slate 400)
- Borders/Dividers: `#334155` (Đường kẻ siêu chìm - Slate 700)

**Brand & Semantic (Màu chủ đạo & Thu/Chi):**
*Lưu ý: Các màu này vẫn giữ Solid, màu Thu/Chi giữ nguyên vì màu sáng tự nổi bật trên nền tối.*
- Primary: `#2DD4BF` (Xanh teal - được đẩy sáng lên một chút so với Light mode để rõ hơn trên nền đen)
- Primary Light (Cho nút phụ/trạng thái Active): `#134E4A` (Xanh teal cực đậm) hoặc dùng `#334155`
- Success (Thu): `#10B981` (Giữ nguyên)
- Danger (Chi): `#EF4444` (Giữ nguyên)

**Shadows & Elevation (Bóng đổ trong Dark Mode):**
- Trọng tâm của Flat Design Dark Mode là **hạn chế bóng đổ**. Các khối (Card) đã tự tách biệt với nền nhờ màu `#1E293B` nổi trên nền `#0F172A`.
- Nếu bắt buộc dùng bóng, dùng mã `#000000` (Đen tuyền) với opacity khoảng `30-40%` và blur nhỏ hơn Light Mode.

## 3. Spacing & Layout
Base unit: `8px`

- `xs`: 4px
- `sm`: 8px
- `md`: 16px (Padding chuẩn cho viền màn hình)
- `lg`: 24px (Khoảng cách giữa các section lớn)
- `xl`: 32px
- `xxl`: 48px

## 4. Shapes & Border Radius
Giữ phong cách bo tròn để tạo cảm giác thân thiện, an toàn.

- `Small`: 8px (Tag thời gian, Badge)
- `Medium`: 16px (Ô input, Card nhỏ, Box chứa Icon)
- `Large`: 24px (Card tổng quan, Dialog popup)
- `Extra Large`: 32px (Hai góc trên của Bottom Sheet)
- `Circular`: 999px (Nút FAB, Avatar)

## 5. Shadows (Elevation)
Đổ bóng siêu mượt và phân tán rộng (thay thế hoàn toàn bóng Material mặc định). Dùng mã màu `#0F172A` làm bóng với độ mờ (opacity) cực thấp.

- **Shadow Sm (Cho List/Card thông thường):** `0px 4px 12px rgba(15, 23, 42, 0.05)`
- **Shadow Md (Cho nút FAB, Popup):** `0px 8px 24px rgba(15, 23, 42, 0.08)`
- **Shadow Top (Cho Bottom Nav, Bottom Sheet):** `0px -4px 16px rgba(15, 23, 42, 0.04)`

## 6. Components

### 6.1 Buttons
- **Primary Button:** Nền `Primary`, Text `White`, Bo góc `Large`, Có `Shadow Md`. Không viền.
- **Secondary Button:** Nền `Primary Light`, Text `Primary`, Bo góc `Large`. Trơn, không đổ bóng.

### 6.2 Inputs (Text Field)
- Nền: `#F1F5F9` (Xám siêu nhạt).
- Viền (Border): Không có (Dùng mảng màu nền tạo Flat Design).
- Focus State: Viền `1.5px solid Primary`, Nền chuyển sang `#FFFFFF`.
- Bo góc: `Medium`.

### 6.3 Category Icons (Khối chứa Icon danh mục)
- Nền: Cùng màu với Icon nhưng để Opacity ở mức `10% - 15%`.
- Màu Icon: 100% Solid color.
- Bo góc: `Medium` (Squircles - Vuông bo góc).

### 6.4 Iconography
- Thư viện Icon khuyên dùng: `Feather Icons` hoặc `Lucide Icons`.
- Đặc điểm: Icon nét thanh (Line icons), bo tròn đầu nét, độ dày nét (stroke width) thống nhất ở `2px`.