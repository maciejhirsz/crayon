var Text = crayon.Text = (function() {
    function Text() {
        Shape.apply(this, arguments);
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
        function render() {
            if (this.options.shadow) {
                this.canvas.setShadow(
                    this.options.shadowX,
                    this.options.shadowY,
                    this.options.shadowBlur,
                    this.options.shadowColor
                );
            }

            if (this.options.fill) this.canvas.ctx.fillStyle = this.options.color.toString();
            this.canvas.ctx.textAlign = this.options.align;
            this.canvas.ctx.textBaseline = this.options.baseline;

            var font = [];
            if (this.options.italic) font.push('italic');
            if (this.options.bold) font.push('bold');
            font.push(this.options.size + 'px');
            font.push(this.options.font);

            this.canvas.ctx.font = font.join(' ');

            if (this.options.fill) this.canvas.ctx.fillText(this.options.label, 0, 0);

            if (this.options.stroke) {
                this.canvas.ctx.lineWidth = this.options.stroke;
                this.canvas.ctx.strokeStyle = this.options.strokeColor.toString();
                this.canvas.ctx.strokeText(this.options.label, 0, 0);
            }
        }
    );

    return Text;
})();