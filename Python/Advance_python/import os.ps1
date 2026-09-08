import os
from pathlib import Path

import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
from pptx import Presentation
from pptx.dml.color import RGBColor
from pptx.enum.text import PP_ALIGN
from pptx.util import Inches, Pt


BASE = Path(__file__).resolve().parent
DATA = BASE / "market_data.csv"
ASSETS = BASE / "_property_ppt_assets"
OUTPUT = BASE / "property_market_insights.pptx"
ASSETS.mkdir(exist_ok=True)


def load_data():
    df = pd.read_csv(DATA)
    for col in ["Price", "Rate per sqft"]:
        df[col] = pd.to_numeric(
            df[col].astype(str).str.replace(",", "", regex=False).str.strip()
        )
    df = df.drop_duplicates().copy()
    df["RERA Approved"] = df["RERA Approval"].eq("Approved by RERA")
    df["Price per sqft"] = df["Price"] / df["Area"]
    return df


def money(value):
    if value >= 1e7:
        return f"₹{value / 1e7:.2f} Cr"
    if value >= 1e5:
        return f"₹{value / 1e5:.1f} L"
    return f"₹{value:,.0f}"


def compact(value):
    return f"{value / 1e7:.1f} Cr" if value >= 1e7 else f"{value / 1e5:.1f} L"


def save_bar(series, title, path, color="#22B8A7", xlabel="Average price"):
    fig, ax = plt.subplots(figsize=(9, 4.8))
    series.sort_values().plot.barh(ax=ax, color=color)
    ax.set_title(title, loc="left", fontsize=16, fontweight="bold")
    ax.set_xlabel(xlabel)
    ax.set_ylabel("")
    ax.grid(axis="x", alpha=0.2)
    ax.set_axisbelow(True)
    for i, v in enumerate(series.sort_values()):
        label = f"{v:.1f} Cr" if "crore" in xlabel else (f"₹{v:,.0f}" if "sqft" in xlabel else compact(v))
        ax.text(v, i, f"  {label}", va="center", fontsize=9)
    fig.tight_layout()
    fig.savefig(path, dpi=180, bbox_inches="tight")
    plt.close(fig)


def save_scatter(df, path):
    sample = df.sample(min(5000, len(df)), random_state=42)
    fig, axes = plt.subplots(1, 2, figsize=(10, 4.4))
    axes[0].scatter(sample["Area"], sample["Price"] / 1e7, s=7, alpha=0.18, color="#247BA0")
    axes[0].set_title("Raw scale: outliers dominate", fontweight="bold")
    axes[0].set_xlabel("Area (sqft)")
    axes[0].set_ylabel("Price (₹ crore)")
    axes[1].scatter(np.log1p(sample["Area"]), np.log1p(sample["Price"]), s=7, alpha=0.18, color="#F08A5D")
    axes[1].set_title("Log scale: size is a strong driver", fontweight="bold")
    axes[1].set_xlabel("log(Area)")
    axes[1].set_ylabel("log(Price)")
    for ax in axes:
        ax.grid(alpha=0.2)
    fig.tight_layout()
    fig.savefig(path, dpi=180, bbox_inches="tight")
    plt.close(fig)


def save_area_bins(df, path):
    bins = (
        df.assign(area_bin=pd.qcut(df["Area"], 10, duplicates="drop"))
        .groupby("area_bin", observed=True)
        .agg(avg_price=("Price", "mean"), avg_ppsf=("Price per sqft", "mean"))
    )
    labels = [f"{int(x.left):,}-{int(x.right):,}" for x in bins.index]
    fig, ax = plt.subplots(figsize=(9, 4.6))
    x = np.arange(len(bins))
    ax.plot(x, bins["avg_price"] / 1e7, marker="o", linewidth=2.5, color="#247BA0", label="Avg price (₹ Cr)")
    ax2 = ax.twinx()
    ax2.plot(x, bins["avg_ppsf"], marker="s", linewidth=2.5, color="#F08A5D", label="Avg price/sqft")
    ax.set_xticks(x, labels, rotation=40, ha="right")
    ax.set_ylabel("Average price (₹ crore)", color="#247BA0")
    ax2.set_ylabel("Average price / sqft (₹)", color="#F08A5D")
    ax.set_title("Bigger homes earn more total value, but not monotonically more per sqft", loc="left", fontweight="bold")
    ax.grid(axis="y", alpha=0.2)
    lines, labels1 = ax.get_legend_handles_labels()
    lines2, labels2 = ax2.get_legend_handles_labels()
    ax.legend(lines + lines2, labels1 + labels2, loc="upper left", frameon=False)
    fig.tight_layout()
    fig.savefig(path, dpi=180, bbox_inches="tight")
    plt.close(fig)


def add_text(slide, text, x, y, w, h, size=18, color="203040", bold=False, align=None):
    box = slide.shapes.add_textbox(Inches(x), Inches(y), Inches(w), Inches(h))
    tf = box.text_frame
    tf.clear()
    p = tf.paragraphs[0]
    p.text = text
    p.font.size = Pt(size)
    p.font.bold = bold
    p.font.name = "Aptos"
    p.font.color.rgb = RGBColor.from_string(color)
    if align:
        p.alignment = align
    return box


def add_bullets(slide, bullets, x, y, w, h, size=18, color="203040"):
    box = slide.shapes.add_textbox(Inches(x), Inches(y), Inches(w), Inches(h))
    tf = box.text_frame
    tf.clear()
    for i, item in enumerate(bullets):
        p = tf.paragraphs[0] if i == 0 else tf.add_paragraph()
        p.text = item
        p.level = 0
        p.font.size = Pt(size)
        p.font.name = "Aptos"
        p.font.color.rgb = RGBColor.from_string(color)
        p.space_after = Pt(10)
    return box


def add_header(slide, title, subtitle=None):
    add_text(slide, title, 0.65, 0.35, 12, 0.5, size=25, color="143642", bold=True)
    if subtitle:
        add_text(slide, subtitle, 0.68, 0.9, 12, 0.3, size=10, color="607D8B")


def add_footer(slide, number):
    add_text(slide, f"Property market analysis  |  {number}", 0.65, 7.15, 12, 0.2, size=8, color="78909C")


def add_image(slide, path, x, y, w=None, h=None):
    slide.shapes.add_picture(str(path), Inches(x), Inches(y), width=Inches(w) if w else None, height=Inches(h) if h else None)


def build_ppt(df):
    prs = Presentation()
    prs.slide_width = Inches(13.333)
    prs.slide_height = Inches(7.5)
    blank = prs.slide_layouts[6]
    navy = "143642"
    teal = "22B8A7"

    max_row = df.loc[df["Price"].idxmax()]
    locality_price = df.groupby("Locality").agg(n=("Price", "size"), avg=("Price", "mean")).query("n >= 10").sort_values("avg", ascending=False)
    locality_rate = df.groupby("Locality").agg(n=("Rate per sqft", "size"), avg=("Rate per sqft", "mean")).query("n >= 10").sort_values("avg", ascending=False)
    status = df.groupby("Status")["Price"].agg(["size", "mean", "median"])
    rera = df.groupby("RERA Approved")["Price"].agg(["size", "mean", "median"])
    bhk = df.groupby("BHK_Count")["Price"].agg(["size", "mean", "median"]).query("size >= 10").sort_values("mean", ascending=False)
    flat_type = df.groupby("Flat Type")["Price"].agg(["size", "mean", "median"]).sort_values("mean", ascending=False)
    builder = df.groupby("Builder Name")["Price"].agg(["size", "mean", "median"]).query("size >= 20").sort_values("mean", ascending=False).head(8)
    company = df.groupby("Company Name")["Price"].agg(["size", "mean", "median"]).query("size >= 20").sort_values("mean", ascending=False).head(8)
    raw_corr = df["Area"].corr(df["Price"])
    log_corr = np.log1p(df["Area"]).corr(np.log1p(df["Price"]))

    # 1. Title
    slide = prs.slides.add_slide(blank)
    slide.background.fill.solid()
    slide.background.fill.fore_color.rgb = RGBColor.from_string(navy)
    add_text(slide, "Gurgaon Property Market", 0.75, 1.25, 11.8, 0.8, size=34, color="FFFFFF", bold=True)
    add_text(slide, "Pricing signals, premium segments and commercial decisions", 0.8, 2.15, 11.5, 0.5, size=20, color="B8E0D2")
    add_text(slide, f"{len(df):,} unique listings after deduplication  |  Prepared 05 Sep 2026", 0.8, 5.9, 11, 0.3, size=12, color="D7E8E4")

    # 2. Executive summary
    slide = prs.slides.add_slide(blank)
    add_header(slide, "Executive readout", "The market is segmented: location and luxury product dominate headline prices.")
    cards = [
        ("₹122.63 Cr", "Costliest listing", "6 BHK DLF Camellias, Sector 42"),
        ("Sector 42", "Highest locality average", "₹50.24 Cr across 60 listings"),
        ("₹55,989", "Highest locality rate", "Average listed rate / sqft"),
        ("+5%", "Ready vs under-construction", "Average price: ₹4.15 Cr vs ₹3.96 Cr"),
    ]
    for i, (big, label, detail) in enumerate(cards):
        x = 0.7 + (i % 2) * 6.2
        y = 1.45 + (i // 2) * 2.35
        shape = slide.shapes.add_shape(1, Inches(x), Inches(y), Inches(5.55), Inches(1.75))
        shape.fill.solid()
        shape.fill.fore_color.rgb = RGBColor.from_string("EAF6F3")
        shape.line.color.rgb = RGBColor.from_string("C7E8E0")
        add_text(slide, big, x + 0.25, y + 0.22, 5, 0.5, size=25, color=teal, bold=True)
        add_text(slide, label, x + 0.25, y + 0.8, 5, 0.3, size=14, color=navy, bold=True)
        add_text(slide, detail, x + 0.25, y + 1.18, 5, 0.3, size=10, color="607D8B")
    add_footer(slide, 2)

    # 3. Costliest flat
    slide = prs.slides.add_slide(blank)
    add_header(slide, "1 | The costliest flat is a clear luxury outlier")
    add_text(slide, money(max_row["Price"]), 0.8, 1.35, 4.6, 0.7, size=34, color=teal, bold=True)
    add_text(slide, "6 BHK Apartment in DLF Camellias", 0.85, 2.15, 5.1, 0.4, size=20, color=navy, bold=True)
    add_bullets(slide, [
        "Sector 42  |  16,500 sqft  |  ₹74,323 listed rate / sqft",
        "Ready to move  |  Not approved by RERA",
        "Builder: Provident Capital  |  Company: DLF",
        "Decision: treat luxury listings separately from mainstream benchmarking.",
    ], 0.9, 2.85, 5.6, 2.8, size=15)
    add_image(slide, ASSETS / "locality_price.png", 6.7, 1.3, w=6.1)
    add_footer(slide, 3)

    # 4. Locality
    slide = prs.slides.add_slide(blank)
    add_header(slide, "2–3 | Sector 42 leads both price and rate")
    add_image(slide, ASSETS / "locality_price.png", 0.65, 1.25, w=6.1)
    add_image(slide, ASSETS / "locality_rate.png", 6.75, 1.25, w=6.0)
    add_text(slide, "Recommendation: use Sector 42 as the luxury benchmark, but require sample counts before generalizing.", 0.85, 6.45, 11.8, 0.35, size=14, color=navy, bold=True)
    add_footer(slide, 4)

    # 5. Status and RERA
    slide = prs.slides.add_slide(blank)
    add_header(slide, "4–5 | Status shows a small ready-to-move premium; RERA does not")
    status_series = status["mean"].reindex(["Ready to move", "Under Construction", "New", "Resale"]).dropna()
    save_bar(status_series / 1e7, "Average price by status (₹ crore)", ASSETS / "status.png", color="#247BA0", xlabel="Average price (₹ crore)")
    rera_series = rera["mean"].rename(index={False: "Not approved", True: "Approved"}) / 1e7
    save_bar(rera_series, "Average price by RERA status (₹ crore)", ASSETS / "rera.png", color="#F08A5D", xlabel="Average price (₹ crore)")
    add_image(slide, ASSETS / "status.png", 0.65, 1.25, w=6.1)
    add_image(slide, ASSETS / "rera.png", 6.75, 1.25, w=6.0)
    add_text(slide, "Ready-to-move avg: ₹4.15 Cr vs under-construction: ₹3.96 Cr (+4.9%). RERA-approved avg: ₹3.86 Cr vs not approved: ₹4.08 Cr (-5.4%).", 0.85, 6.25, 11.8, 0.5, size=13, color=navy, bold=True)
    add_footer(slide, 5)

    # 6. Area
    slide = prs.slides.add_slide(blank)
    add_header(slide, "6 | Area raises total price, but the relationship is non-linear")
    add_image(slide, ASSETS / "area_price.png", 0.7, 1.15, w=6.2)
    add_image(slide, ASSETS / "area_bins.png", 6.85, 1.15, w=5.9)
    add_bullets(slide, [
        f"Raw correlation: {raw_corr:.3f}; log-scale correlation: {log_corr:.3f}.",
        "The log view is more informative because ultra-large plots and luxury homes distort the raw scale.",
        "Use area as a core pricing driver, but model location, product type and segment alongside it.",
    ], 0.95, 5.55, 11.5, 1.1, size=12)
    add_footer(slide, 6)

    # 7. BHK
    slide = prs.slides.add_slide(blank)
    add_header(slide, "7 | Larger BHK configurations command the highest averages")
    bhk_plot = bhk.head(7).sort_values("mean")
    save_bar(bhk_plot["mean"], "Average price by BHK (groups with 10+ listings)", ASSETS / "bhk.png", color="#22B8A7")
    add_image(slide, ASSETS / "bhk.png", 0.7, 1.2, w=7.0)
    top_bhk = bhk.index[0]
    add_text(slide, f"{int(top_bhk)} BHK leads at {money(bhk.iloc[0]['mean'])} average", 8.0, 1.75, 4.5, 0.65, size=22, color=teal, bold=True)
    add_bullets(slide, [
        "7 BHK has the highest average, but only 16 listings.",
        "6 BHK is the stronger luxury signal with 89 listings.",
        "Decision: target 4–6 BHK premium inventory; treat 7+ BHK as a low-volume niche.",
    ], 8.0, 2.7, 4.5, 2.7, size=15)
    add_footer(slide, 7)

    # 8. Property type
    slide = prs.slides.add_slide(blank)
    add_header(slide, "8 | Penthouse is the costliest property type; apartments drive scale")
    save_bar(flat_type["mean"], "Average price by property type", ASSETS / "flat_type.png", color="#F08A5D")
    add_image(slide, ASSETS / "flat_type.png", 0.7, 1.25, w=6.7)
    add_bullets(slide, [
        f"Penthouse: {money(flat_type.loc['Penthouse', 'mean'])} average, but only {int(flat_type.loc['Penthouse', 'size'])} listings.",
        f"Apartment: {money(flat_type.loc['Apartment', 'mean'])} average across {int(flat_type.loc['Apartment', 'size']):,} listings.",
        "Decision: separate premium inventory from mass-market volume in pricing and marketing dashboards.",
    ], 7.75, 1.65, 4.7, 3.1, size=16)
    add_footer(slide, 8)

    # 9. Builder/company
    slide = prs.slides.add_slide(blank)
    add_header(slide, "9 | Some builders and companies price higher—but mix matters")
    save_bar(builder["mean"], "Top builders by average price (20+ listings)", ASSETS / "builders.png", color="#247BA0")
    save_bar(company["mean"], "Top companies by average price (20+ listings)", ASSETS / "companies.png", color="#22B8A7")
    add_image(slide, ASSETS / "builders.png", 0.65, 1.25, w=6.1)
    add_image(slide, ASSETS / "companies.png", 6.75, 1.25, w=6.0)
    add_text(slide, "Use builder/company as a premium signal, not a causal claim: high-end inventory mix can explain much of the gap.", 0.85, 6.35, 11.8, 0.35, size=13, color=navy, bold=True)
    add_footer(slide, 9)

    # 10. Price per sqft
    slide = prs.slides.add_slide(blank)
    add_header(slide, "10 | Larger homes are not always more expensive per square foot")
    add_image(slide, ASSETS / "area_bins.png", 0.75, 1.25, w=7.0)
    add_text(slide, "Answer: No", 8.2, 1.6, 3.7, 0.7, size=34, color="F08A5D", bold=True)
    add_bullets(slide, [
        "Average price / sqft rises and falls across area deciles.",
        "Product type and location can outweigh size: premium smaller homes can command high rates.",
        "Price on total value for portfolio decisions; use rate / sqft for apples-to-apples comparisons.",
    ], 8.2, 2.55, 4.2, 2.9, size=16)
    add_footer(slide, 10)

    # 11. Decision slide
    slide = prs.slides.add_slide(blank)
    add_header(slide, "Decision playbook", "Translate the data into pricing, targeting and governance actions.")
    actions = [
        ("1", "Segment first", "Separate luxury (Sector 42 / 5–7 BHK / penthouse) from mainstream inventory before benchmarking."),
        ("2", "Price with multiple drivers", "Use area + locality + BHK + property type + builder/company; do not rely on area alone."),
        ("3", "Avoid RERA overpricing assumptions", "This sample shows no positive RERA price premium; validate with like-for-like comparisons."),
        ("4", "Use rate / sqft carefully", "Rate is useful for comparability, but it is not a monotonic function of home size."),
    ]
    for i, (n, title, detail) in enumerate(actions):
        y = 1.35 + i * 1.25
        add_text(slide, n, 0.85, y, 0.5, 0.5, size=26, color=teal, bold=True, align=PP_ALIGN.CENTER)
        add_text(slide, title, 1.55, y, 3.1, 0.35, size=17, color=navy, bold=True)
        add_text(slide, detail, 4.5, y, 7.7, 0.55, size=14, color="455A64")
    add_text(slide, "Bottom line: premium pricing is primarily a location-and-product story, not simply a size or RERA story.", 0.9, 6.4, 11.7, 0.4, size=18, color=navy, bold=True)
    add_footer(slide, 11)

    # 12. Methodology
    slide = prs.slides.add_slide(blank)
    add_header(slide, "Methodology and caveats")
    add_bullets(slide, [
        f"Source: market_data.csv; {len(pd.read_csv(DATA)):,} raw rows reduced to {len(df):,} unique listings after exact-duplicate removal.",
        "Price and rate fields were parsed from text; price / sqft was calculated as Price ÷ Area.",
        "Locality, builder and company comparisons use at least 10 listings for locality and 20 for builder/company.",
        "BHK groups with fewer than 10 listings are excluded from the ranked comparison; averages are sensitive to luxury outliers.",
        "Associations are descriptive, not causal; a like-for-like regression or matched comparison is the next step.",
    ], 0.95, 1.45, 11.5, 4.4, size=17)
    add_footer(slide, 12)

    prs.save(OUTPUT)


if __name__ == "__main__":
    data = load_data()
    locality_price = data.groupby("Locality").agg(n=("Price", "size"), avg=("Price", "mean")).query("n >= 10").sort_values("avg", ascending=False).head(10)["avg"]
    locality_rate = data.groupby("Locality").agg(n=("Rate per sqft", "size"), avg=("Rate per sqft", "mean")).query("n >= 10").sort_values("avg", ascending=False).head(10)["avg"]
    status = data.groupby("Status")["Price"].mean().reindex(["Ready to move", "Under Construction", "New", "Resale"]).dropna() / 1e7
    rera = data.groupby("RERA Approved")["Price"].mean().rename(index={False: "Not approved", True: "Approved"}) / 1e7
    save_bar(locality_price, "Top localities by average price (10+ listings)", ASSETS / "locality_price.png", color="#22B8A7")
    save_bar(locality_rate, "Top localities by average rate / sqft (10+ listings)", ASSETS / "locality_rate.png", color="#F08A5D", xlabel="Average rate / sqft (₹)")
    save_bar(status, "Average price by status (₹ crore)", ASSETS / "status.png", color="#247BA0", xlabel="Average price (₹ crore)")
    save_bar(rera, "Average price by RERA status (₹ crore)", ASSETS / "rera.png", color="#F08A5D", xlabel="Average price (₹ crore)")
    save_scatter(data, ASSETS / "area_price.png")
    save_area_bins(data, ASSETS / "area_bins.png")
    build_ppt(data)
    print(f"Created {OUTPUT}")
