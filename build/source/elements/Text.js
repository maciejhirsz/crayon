var Text = crayon.Text = (function() {
    function Text(options) {
        Shape.call(this, options);
    }

    extend(Text, Shape);
    defaults(Text, {
        label    : 'crayon',
        align    : 'center', // left|right|center
        baseline : 'middle', // top|hanging|middle|alphabetic|ideographic|bottom
        italic   : false,
        bold     : false,
        size     : 12,
        font     : 'sans-serif'
    });
    methods(Text,
        function render(canvas) {
            if (this.options.shadow) {
                canvas.setShadow(
                    this.options.shadowX,
                    this.options.shadowY,
                    this.options.shadowBlur,
                    this.options.shadowColor
                );
            }

            if (this.options.fill) canvas.ctx.fillStyle = this.options.color.toString();
            canvas.ctx.textAlign = this.options.align;
            canvas.ctx.textBaseline = this.options.baseline;

            var font = [];
            if (this.options.italic) font.push('italic');
            if (this.options.bold) font.push('bold');
            font.push(this.options.size + 'px');
            font.push(this.options.font);

            canvas.ctx.font = font.join(' ');

            if (this.options.fill) canvas.ctx.fillText(this.options.label, 0, 0);

            if (this.options.stroke) {
                canvas.ctx.lineWidth = this.options.stroke;
                canvas.ctx.strokeStyle = this.options.strokeColor.toString();
                canvas.ctx.strokeText(this.options.label, 0, 0);
            }
        }
    );

    return Text;
})();